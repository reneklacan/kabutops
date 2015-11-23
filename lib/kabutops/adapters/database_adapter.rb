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
          process_one(resource, page, result)
        end
      end

      def process_one resource, page, result
        result.update(updated_at: Time.now.to_i)
        save = (notify(:save_if, resource, page, result) || []).all?

        logger.info("#{self.class.to_s} outputs:") if debug
        notify(:before_save, result) if save
        logger.info(save ? result.to_hash : 'not valid for save') if debug
        store(result) if save && !debug
        notify(:after_save, result) if save
        result
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
