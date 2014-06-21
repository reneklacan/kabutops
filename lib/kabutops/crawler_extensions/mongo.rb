# -*- encoding : utf-8 -*-

module Kabutops

  module CrawlerExtensions

    module Mongo
      extend Extensions::Includable

      module ClassMethods
        def mongo &block
          adapters << Adapters::Mongo.new(&block)
        end
      end
    end

  end

end
