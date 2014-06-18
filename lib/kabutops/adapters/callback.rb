module Kabutops
  module Adapters
    class Callback < Base
      attr_accessor :block

      def initialize block
        @block = block
      end

      def process resource, page
        block.call(resource, page)
      end
    end
  end
end
