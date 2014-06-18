module Kabutops

  class Crawler
    include CrawlerExtensions::Debugging
    include CrawlerExtensions::PStoreStorage
    include CrawlerExtensions::Callback
    include CrawlerExtensions::ElasticSearch

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

      def << resource
        perform_async(resource)
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
