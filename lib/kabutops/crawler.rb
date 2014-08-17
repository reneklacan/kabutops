# -*- encoding : utf-8 -*-

module Kabutops

  class Crawler
    include Extensions::Logging
    include CrawlerExtensions::Debugging
    include CrawlerExtensions::PStoreStorage
    include CrawlerExtensions::ElasticSearch
    include CrawlerExtensions::Redis
    include CrawlerExtensions::Mongo
    include Sidekiq::Worker

    class << self
      include Extensions::Parameterable
      include Extensions::CallbackSupport

      params :collection, :proxy, :cache, :wait,
             :skip_existing, :agent, :encoding
      callbacks :after_crawl, :before_cache, :store_if

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

      adapters = self.class.adapters.select do |adapter|
        params.skip_existing ? adapter.find(resource).nil? : true
      end

      return if adapters.nil?
      page = crawl(resource)
      return if page.nil?
      return unless (self.class.notify(:store_if, resource, page) || []).all?

      adapters.each do |adapter|
        adapter.process(resource, page)
      end
    rescue Exception => e
      unless self.class.debug
        logger.error(e.message)
        logger.error(e.backtrace.join("\n"))
      end

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
      page = get_cache_or_hit(resource)
      self.class.notify(:after_crawl, resource, page)
      page
    rescue Mechanize::ResponseCodeError => e
      if e.response_code.to_i == 404
        nil
      else
        p e.response_code
        raise
      end
    end

    def get_cache_or_hit resource
      cache_key = (resource[:id] || Digest::SHA256.hexdigest(resource[:url])).to_s
      page = nil

      content = Cachy.cache_if(params.cache, cache_key) do
        sleep params[:wait] || 0 # wait only if value is not from cache
        page = get_page(resource[:url])
        self.class.notify(:before_cache, resource, page)
        page.to_s
      end

      page ? page : Nokogiri::HTML(content)
    end

    def get_page url
      body = agent.get(url).body
      body.encode!('utf-8', params[:encoding]) if params[:encoding]
      Nokogiri::HTML(body)
    end

    def agent
      if params[:agent].is_a?(Proc)
        @agent = params[:agent].call
      elsif @agent.nil?
        @agent = params[:agent] || Mechanize.new
        @agent.set_proxy(*params[:proxy]) if params[:proxy]
      end

      @agent
    end
  end

end
