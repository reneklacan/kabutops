module Kabutops

  module Adapters

    class DatabaseAdapter < Base
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
