# -*- encoding : utf-8 -*-

module Kabutops

  class RecipeItem
    attr_reader :type, :value

    def initialize type, value
      @type = type
      @value = value
    end

    def process resource, page
      case @type
      when :var
        resource[@value]
      when :recipe
        @value.process(resource, page)
      when :css
        page.css(@value).text
      when :xpath
        page.xpath(@value).text
      when :lambda, :proc
        @value.call(resource, page)
      else
        raise "unknown recipe item type '#{item.type}'"
      end
    end
  end

end
