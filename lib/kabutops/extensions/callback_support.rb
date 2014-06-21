# -*- encoding : utf-8 -*-

module Kabutops

  module Extensions

    module CallbackSupport
      extend Includable

      class Manager
        attr_reader :map, :allowed

        def initialize allowed=nil
          @allowed = allowed || []
          @map ||= Hashie::Mash.new
        end

        def method_missing name, *args, &block
          return super unless block_given?

          unless @allowed.include?(name)
            raise "Invalid callback name: #{name}"
          end

          @map[name] ||= []
          @map[name] << block
        end

        def notify name, *args
          return unless @map

          (@map[name] || []).map do |block|
            block.call(*args)
          end
        end
      end

      def callbacks &block
        @manager ||= Manager.new(allowed_callbacks)
        @manager.instance_eval &block
      end

      def notify name, *args
        @manager ||= Manager.new(allowed_callbacks)
        @manager.notify(name, *args)
      end

      module ClassMethods
        def callbacks *args
          define_method :allowed_callbacks do
            args
          end
        end
      end
    end

  end

end
