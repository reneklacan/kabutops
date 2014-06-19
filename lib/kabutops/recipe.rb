# -*- encoding : utf-8 -*-

module Kabutops

  class Recipe
    def initialize
      @items = Hashie::Mash.new
      @nested = false
    end

    def method_missing name, *args, &block
      if block_given?
        recipe = Recipe.new
        recipe.instance_eval &block
        @items[name] = RecipeItem.new(name, :recipe, recipe)
        @nested = true
      else
        type, value = args[0..1]
        @items[name] = RecipeItem.new(name, type, value)
      end
    end

    def process resource, page
      result = Hashie::Mash.new

      @items.each do |name, item|
        result[name] = case item.type
        when :var
          resource[item.value]
        when :recipe
          item.value.process(resource, page)
        when :css
          page.css(item.value).text
        when :xpath
          page.xpath(item.value).text
        when :lambda
          item.value.call(resource, page)
        when :proc
          page.instance_eval &item.value
        else
          raise "unknown recipe item type '#{item.type}'"
        end
      end

      result
    end

    def nested?
      @nested
    end
  end

end
