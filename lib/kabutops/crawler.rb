module Kabutops
  class Crawler
    include CrawlerExtensions::ElasticSearch
    include CrawlerExtensions::Callback

    class << self
      include CrawlerExtensions::PStoreStorage

      attr_reader :params

      [
        :collection,
        :workers,
        :proxy,
        :cache
      ].each do |name|
        define_method name do |*args|
          @params ||= {}
          if args.size == 1
            @params[name] = args[0]
          else
            @params[name] = args
          end
        end
      end

      def params
        @params
      end

      def adapters
        @adapters
      end

      def crawl! collection=nil
        if storage(:status) == :none
          @collection = collection || @params[:collection] || []
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
      resource = resource.inject({}) { |h, (k, v)| h[k.to_sym] = v; h }

      content = Cachy.cache_if(self.class.params[:cache], resource[:url]) do
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
      self.class.perform_async(resource)
    end
  end
end
