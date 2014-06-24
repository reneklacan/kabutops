# -*- encoding : utf-8 -*-

module Kabutops

  module Adapters

    class DatabaseAdapter < Base
      include Extensions::Logging
      include Extensions::CallbackSupport

      attr_reader :recipe

      callbacks :after_save

      def data &block
        @recipe = Recipe.new
        @recipe.instance_eval &block
      end

      def process resource, page
        raise 'data block not defined' unless @recipe

        result = @recipe.process(resource, page)
        result.update(updated_at: Time.now.to_i)

        if debug
          logger.info("#{self.class.to_s} outputs:")
          logger.info(result.to_hash)
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
