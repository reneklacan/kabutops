# -*- encoding : utf-8 -*-

module Kabutops

  module Adapters

    class Base
      def initialize(&block)
        instance_eval(&block)
      end

      def enable_debug
        @debug = true
      end

      def debug
        !!@debug
      end
    end

  end

end
