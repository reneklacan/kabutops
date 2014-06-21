# -*- encoding : utf-8 -*-

module Kabutops

  module CrawlerExtensions

    module PStoreStorage
      extend Extensions::Includable

      class Storage
        def initialize path='.kabutopus.config.pstore'
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

      module ClassMethods
        def storage
          @storage ||= Storage.new
        end
      end

      def storage
        self.class.storage
      end
    end

  end

end
