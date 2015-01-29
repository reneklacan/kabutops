# -*- encoding : utf-8 -*-

module Kabutops

  module Adapters

    class DatabaseAdapter < Base
      include Extensions::Logging
      include Extensions::CallbackSupport

      attr_reader :recipe

      callbacks :before_save, :after_save, :save_if

      def data params={}, &block
        @recipe = Recipe.new(params)
        @recipe.instance_eval &block
      end

      def process resource, page
        raise 'data block not defined' unless recipe

        previous = find(resource)

        [recipe.process(resource, page, previous)].flatten.each do |result|
          result.update(updated_at: Time.now.to_i)
          save = (notify(:save_if, resource, page, result) || []).all?

          if debug
            logger.info("#{self.class.to_s} outputs:")
            notify(:before_save, result) if save
            logger.info(save ? result.to_hash : 'not valid for save')
            notify(:after_save, result) if save
          elsif save
            notify(:before_save, result)
            store(result)
            notify(:after_save, result)
          end
        end
      end

      def store result
        raise NotImplementedError
      end

      def find resource
        raise NotImplementedError
      end
    end

  end

end
