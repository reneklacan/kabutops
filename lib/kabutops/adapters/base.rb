module Kabutops

  module Adapters

    class Base
      def enable_debug
        @debug = true
      end

      def debug
        @debug == true
      end
    end
    
  end

end
