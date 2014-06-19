# -*- encoding : utf-8 -*-

module Kabutops

  module Extensions

    module CallbackSupport

      class Manager
        def method_missing name, *args, &block
          return unless block_given?

          @map ||= Hashie::Mash.new
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
        @manager ||= Manager.new
        @manager.instance_eval &block
      end

      def notify name, *args
        @manager ||= Manager.new
        @manager.notify(name, *args)
      end
    end

  end

end
