# -*- encoding : utf-8 -*-

module Kabutops

  class Recipe
    attr_reader :items

    def initialize
      @items = Hashie::Mash.new
      @nested = false
    end

    def method_missing name, *args, &block
      if block_given?
        recipe = Recipe.new
        recipe.instance_eval &block
        @items[name] = RecipeItem.new(:recipe, recipe)
        @nested = true
      else
        type, value = args[0..1]
        @items[name] = RecipeItem.new(type, value)
      end
    end

    def process resource, page
      result = Hashie::Mash.new

      @items.each do |name, item|
        result[name] = item.process(resource, page)
      end

      result
    end

    def nested?
      @nested
    end
  end

end
