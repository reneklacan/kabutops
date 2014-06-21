# -*- encoding : utf-8 -*-

module Kabutops

  module CrawlerExtensions

    module Mongo

      def self.included base
        base.extend(ClassMethods)
      end

      module ClassMethods
        def mongo &block
          adapters << Adapters::Mongo.new(&block)
        end
      end

    end

  end

end
