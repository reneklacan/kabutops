# -*- encoding : utf-8 -*-

module Kabutops

  module CrawlerExtensions

    module Redis

      def self.included base
        base.extend(ClassMethods)
      end

      module ClassMethods
        def redis &block
          adapters << Adapters::Redis.new(&block)
        end
      end

    end

  end

end
