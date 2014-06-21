# -*- encoding : utf-8 -*-

module Kabutops

  module CrawlerExtensions

    module ElasticSearch
      extend Extensions::Includable

      module ClassMethods
        def elasticsearch &block
          adapters << Adapters::ElasticSearch.new(&block)
        end
      end
    end

  end

end
