module Kabutops

  module CrawlerExtensions

    module PStoreStorage

      def check_storage
        @storage ||= PStore.new(".kabutopus.config.pstore")
      end

      def storage= name, value
        check_storage
        @storage.transaction do
          @storage[key.to_sym] = value
        end
      end

      def storage key
        check_storage
        @storage.transaction { @storage[key.to_sym] }
      end

    end

  end

end
