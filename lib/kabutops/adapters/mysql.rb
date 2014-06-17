module Kabutops
  module Adapters
    class MySQL < DatabaseAdapter
      def table value
        @table = value
      end

      def nested?
        false
      end
    end
  end
end
