# -*- encoding : utf-8 -*-

module Kabutops

  module CrawlerExtensions

    module ElasticSearch

      def self.included base
        base.extend(ClassMethods)
      end

      module ClassMethods
        def elasticsearch &block
          adapters << Adapters::ElasticSearch.new(&block)
        end
      end

    end

  end

end
