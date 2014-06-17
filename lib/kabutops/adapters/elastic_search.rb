module Kabutops
  module Adapters
    class ElasticSearch < DatabaseAdapter
      def index value
        @index = value
      end

      def document value
        @document = value
      end

      def store result
        p result
        p result
        p result
      end

      def nested?
        true
      end
    end
  end
end
