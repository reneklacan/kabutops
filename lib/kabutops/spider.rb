# -*- encoding : utf-8 -*-

module Kabutops

  class Spider < Crawler
    class << self
      params :url
      callbacks :after_crawl, :before_cache, :follow_if

      def debug_spider
        enable_debug
        self.new.perform({
          url: params[:url]
        })
      end

      def crawl collection=nil
        super(collection || [{ url: params.url, }])
      end

      def << resource
        if resource_status(resource).nil?
          resource_status(resource, 'new')
          super
        end
      end

      def resource_status resource, status=nil
        url_status(resource[:url], status)
      end

      def url_status url, status=nil
        key = redis_key(url)

        if status
          redis.set(
            key,
            JSON.dump({
              url: url,
              status: status,
            })
          )
        else
          item = redis.get(key)
          item ? JSON.parse(item)['status'] : nil
        end
      end

      protected

      def redis_key string
        Digest::SHA256.hexdigest(string)
      end

      def redis
        @redis ||= ::Redis::Namespace.new(
          self.to_s,
          redis: ::Redis.new(
            host: Configuration[:redis][:host],
            port: Configuration[:redis][:port],
            db: Configuration[:redis][:db],
          )
        )
      end
    end

    def crawl resource
      page = super
      after_crawl(resource, page)
      self.class.resource_status(resource, 'done')
      page
    end

    def after_crawl resource, page
      page.css('a').each do |a|
        follow = self.class.notify(:follow_if, a['href']).any?
        if follow
          self << {
            url: URI.join(params.url, URI.escape(a['href'])).to_s
          }
        end
      end
    end
  end

end
