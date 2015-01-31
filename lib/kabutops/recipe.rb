# -*- encoding : utf-8 -*-

module Kabutops

  class Recipe
    attr_reader :items, :params, :nested

    def initialize params={}
      @params = Hashie::Mash.new(params)
      @items = Hashie::Mash.new
      @nested = false
    end

    def method_missing name, *args, &block
      if block_given?
        recipe = Recipe.new
        recipe.instance_eval(&block)
        @items[name] = RecipeItem.new(:recipe, recipe)
        @nested = true
      else
        type, value, convert_to = args[0..2]
        @items[name] = RecipeItem.new(type, value, convert_to)
      end
    end

    def process resource, page, previous
      if @params[:each]
        page.xpath(@params[:each]).map{ |n| process_one(resource, n, previous) }
      elsif @params[:each_css]
        page.css(@params[:each_css]).map{ |n| process_one(resource, n, previous) }
      else
        process_one(resource, page, previous)
      end
    end

    def process_one resource, node, previous
      result = Hashie::Mash.new

      items.each do |name, item|
        result[name] = item.process(resource, node, previous)
      end

      result
    end

    def nested?
      @nested
    end
  end

end
