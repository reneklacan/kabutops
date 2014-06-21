# -*- encoding : utf-8 -*-

module Kabutops

  module CrawlerExtensions

    module Sequel
      extend Extensions::Includable

      module ClassMethods
        def sequel &block
          adapters << Adapters::Sequel.new(&block)
        end
      end
    end

  end

end
