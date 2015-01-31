# -*- encoding : utf-8 -*-

module Kabutops

  class RecipeItem
    TYPES = [:var, :recipe, :css, :xpath, :lambda, :proc, :const, :static]

    attr_reader :type, :value

    def initialize type, value, convert_to=nil
      raise "Unknown recipe item type '#{type}'" unless TYPES.include?(type.to_sym)

      @type = type.to_sym
      @value = value
      @convert_to = convert_to
    end

    def process resource, page, previous
      convert(get(resource, page, previous))
    end

    protected

    def get resource, page, previous
      case type
      when :var
        resource[value]
      when :recipe
        value.process(resource, page, previous)
      when :css
        page.css(value).text.gsub(/\u00a0/, ' ').strip
      when :xpath
        page.xpath(value).text.gsub(/\u00a0/, ' ').strip
      when :lambda, :proc
        value.call(resource, page, previous)
      when :const, :static
        value
      end
    end

    def convert v
      return nil if v.nil?

      case @convert_to
      when nil then v
      when :int then v[/\d+/].to_i
      when :float then v.gsub(',', '.')[/\d+(\.\d+)?/].to_f
      else raise "Unknown conversion type '#{@convert_to}'"
      end
    end
  end

end
