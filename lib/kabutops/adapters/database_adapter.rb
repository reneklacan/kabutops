# -*- encoding : utf-8 -*-

module Kabutops

  module Adapters

    class DatabaseAdapter < Base
      include Extensions::CallbackSupport

      def data &block
        @recipe = Recipe.new
        @recipe.instance_eval &block
      end

      def process resource, page
        result = @recipe.process(resource, page)
        if debug
          puts "#{self.class.to_s} outputs:"
          p result.to_hash
        else
          store(result)
          notify(:after_save, result)
        end
      end

      def store result
        raise NotImplementedError
      end

      def nested?
        raise NotImplementedError
      end
    end

  end

end
