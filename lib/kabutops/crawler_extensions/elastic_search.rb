# -*- encoding : utf-8 -*-

module Kabutops

  module CrawlerExtensions

    module ElasticSearch

      def self.included base
        base.extend(ClassMethods)
      end

      module ClassMethods
        def elasticsearch &block
          adapter = Adapters::ElasticSearch.new
          adapter.instance_eval &block

          @adapters ||= []
          @adapters << adapter
        end
      end

    end

  end

end
