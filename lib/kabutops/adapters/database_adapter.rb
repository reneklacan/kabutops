module Kabutops
  module Adapters
    class DatabaseAdapter
      def data &block
        @recipe = Recipe.new
        @recipe.instance_eval &block
      end

      def process resource, page
        result = @recipe.process(resource, page)
        store(result)
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
