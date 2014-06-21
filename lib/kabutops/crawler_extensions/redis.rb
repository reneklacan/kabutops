# -*- encoding : utf-8 -*-

module Kabutops

  module CrawlerExtensions

    module Redis
      extend Extensions::Includable

      module ClassMethods
        def redis &block
          adapters << Adapters::Redis.new(&block)
        end
      end
    end

  end

end
