# -*- encoding : utf-8 -*-

module Kabutops

  class Crawler
    include CrawlerExtensions::Debugging
    include CrawlerExtensions::PStoreStorage
    include CrawlerExtensions::ElasticSearch
    include CrawlerExtensions::Redis
    include Sidekiq::Worker

    class << self
      include Extensions::Parameterable
      include Extensions::CallbackSupport

      params :collection, :proxy, :cache, :wait
      callbacks :after_crawl

      def adapters
        @adapters || []
      end

      def crawl! collection=nil
        @map ||= Hashie::Mash.new

        if storage[:status].nil?
          (collection || params[:collection] || []).each do |resource|
            self << resource
          end
        end
      end

      def << resource
        if debug
          params[:collection] ||= []
          params[:collection] << resource
          return
        end

        key = resource[:id] || resource[:url]
        @map ||= Hashie::Mash.new

        if key.nil?
          raise "url must be specified for resource"
        elsif @map[key]
          # resource with an id already in map
        else
          perform_async(resource.to_hash)
          @map[key] = resource
        end
      end
    end

    def perform resource
      resource = Hashie::Mash.new(resource)
      page = crawl(resource)

      self.class.adapters.each do |adapter|
        adapter.process(resource, page)
      end
    end

    def << resource
      self.class << resource
    end

    protected

    def crawl resource
      content = Cachy.cache_if(self.class.params.cache, resource[:url]) do
        sleep self.class.params[:wait] || 0 # wait only if value is not from cache
        agent.get(resource[:url]).body
      end

      page = Nokogiri::HTML(content)
      self.class.notify(:after_crawl, resource, page)
      page
    end

    def agent
      unless @agent
        @agent = Mechanize.new
        @agent.set_proxy(*self.class.params[:proxy]) if self.class.params[:proxy]
      end

      @agent
    end
  end

end
