# -*- encoding : utf-8 -*-

module Kabutops

  module Adapters

    class Base
      def initialize &block
        instance_eval &block if block_given?
      end

      def enable_debug
        @debug = true
      end

      def debug
        @debug == true
      end
    end

  end

end
