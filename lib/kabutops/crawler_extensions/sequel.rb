# -*- encoding : utf-8 -*-

module Kabutops

  module CrawlerExtensions

    module Sequel

      def self.included base
        base.extend(ClassMethods)
      end

      module ClassMethods
        def sequel &block
          adapters << Adapters::Sequel.new(&block)
        end
      end

    end

  end

end
