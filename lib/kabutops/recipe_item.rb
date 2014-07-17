# -*- encoding : utf-8 -*-

module Kabutops

  class RecipeItem
    attr_reader :type, :value

    def initialize type, value, convert_to=nil
      @type = type
      @value = value
      @convert_to = convert_to
    end

    def process resource, page
      convert(get(resource, page))
    end

    protected

    def get resource, page
      case @type
      when :var
        resource[@value]
      when :recipe
        @value.process(resource, page)
      when :css
        page.css(@value).text.gsub(/\u00a0/, ' ').strip
      when :xpath
        page.xpath(@value).text.gsub(/\u00a0/, ' ').strip
      when :lambda, :proc
        @value.call(resource, page)
      else
        raise "unknown recipe item type '#{item.type}'"
      end
    end

    def convert v
      return nil if v.nil?

      case @convert_to
      when nil then v
      when :int then v[/\d+/].to_i
      when :float then v[/\d+(\.\d+)?/].to_f
      end
    end
  end


end
