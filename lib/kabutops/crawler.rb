# -*- encoding : utf-8 -*-

module Kabutops

  class Crawler
    include Extensions::Logging
    include CrawlerExtensions::Debugging
    include CrawlerExtensions::PStoreStorage
    include CrawlerExtensions::ElasticSearch
    include CrawlerExtensions::Redis
    include CrawlerExtensions::Mongo
    include CrawlerExtensions::Sequel
    include Sidekiq::Worker

    class << self
      include Extensions::Parameterable
      include Extensions::CallbackSupport

      params :collection, :proxy, :cache, :wait, :skip_existing
      callbacks :after_crawl

      def adapters
        @adapters ||= []
      end

      def reset!
        storage[:status] = nil
      end

      def crawl! collection=nil
        reset!
        crawl(collection)
      end

      def crawl collection=nil
        if storage[:status].nil?
          (collection || params[:collection] || []).each do |resource|
            self << resource
          end
          storage[:status] = :in_progress
        elsif storage[:status] == :in_progress
          # pass
        end
      end

      def << resource
        if debug
          params[:collection] ||= []
          params[:collection] << resource
          return
        end

        key = resource[:id] || resource[:url]

        if key.nil?
          raise "url must be specified for resource"
        else
          perform_async(resource.to_hash)
        end
      end
    end

    def perform resource
      resource = Hashie::Mash.new(resource)

      adapters ||= self.class.adapters.select do |adapter|
        if params.skip_existing && adapter.respond_to?(:find)
          adapter.find(resource).nil?
        else
          true
        end
      end

      return if adapters.nil?

      page = crawl(resource)

      adapters.each do |adapter|
        adapter.process(resource, page)
      end
    rescue Exception => e
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      sleep params[:wait] || 0
      raise e
    end

    def << resource
      self.class << resource
    end

    protected

    def params
      self.class.params
    end

    def crawl resource
      cache_key = (resource[:id] || resource[:url]).to_s
      content = Cachy.cache_if(params.cache, cache_key) do
        sleep params[:wait] || 0 # wait only if value is not from cache
        agent.get(resource[:url]).body
      end

      page = Nokogiri::HTML(content)
      self.class.notify(:after_crawl, resource, page)
      page
    end

    def agent
      unless @agent
        @agent = Mechanize.new
        @agent.set_proxy(*params[:proxy]) if params[:proxy]
      end

      @agent
    end
  end

end
