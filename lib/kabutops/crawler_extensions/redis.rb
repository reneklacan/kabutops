# -*- encoding : utf-8 -*-

module Kabutops

  module CrawlerExtensions

    module Redis

      def self.included base
        base.extend(ClassMethods)
      end

      module ClassMethods
        def redis &block
          adapter = Adapters::Redis.new
          adapter.instance_eval &block

          @adapters ||= []
          @adapters << adapter
        end
      end

    end

  end

end
