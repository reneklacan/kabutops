module Kabutops

  class Crawler
    include CrawlerExtensions::ElasticSearch
    include CrawlerExtensions::Callback
    include CrawlerExtensions::PStoreStorage

    class << self
      include Parameterable

      params :collection, :proxy, :cache

      def adapters
        @adapters
      end

      def crawl! collection=nil
        if storage[:status] == :none
          @collection = collection || params[:collection] || []
          @collection.each do |resource|
            raise "url must be specified" if resource[:id].nil?
            perform_async(resource)
          end
        end
      end

      def debug_first
        debug_resource(params[:collection].first)
      end

      def debug_random count=1
        params[:collection].sample(count).each{ |r| debug_resource(r) }
      end

      def debug_resource resource
        enable_debug
        self.new.perform(resource)
      end

      def << resource
        perform_async(resource)
      end

      private

      def enable_debug
        @adapters.each { |a| a.enable_debug }
      end
    end

    def perform resource
      resource = Hashie::Mash.new(resource)

      content = Cachy.cache_if(self.class.params.cache, resource[:url]) do
        agent = Mechanize.new
        #agent.set_proxy(*self.class.params[:proxy])
        agent.get(resource[:url]).body
      end

      page = Nokogiri::HTML(content)

      self.class.adapters.each do |adapter|
        adapter.process(resource, page)
      end
    end

    def << resource
      self.class.perform_async(resource.to_hash)
    end
  end

end
