# -*- encoding : utf-8 -*-

module Kabutops

  module CrawlerExtensions

    module PStoreStorage
      class Storage
        def initialize path
          @storage ||= PStore.new(path)
        end

        def [] key
          @storage.transaction { @storage[key.to_sym] }
        end

        def []= key, value
          @storage.transaction do
            @storage[key.to_sym] = value
          end
        end
      end

      def self.included base
        base.extend(ClassMethods)
      end

      module ClassMethods

        def storage
          @storage ||= Storage.new(".kabutopus.config.pstore")
        end

      end

      def storage
        self.class.storage
      end

    end

  end

end
