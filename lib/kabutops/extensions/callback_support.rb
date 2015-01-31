# -*- encoding : utf-8 -*-

module Kabutops

  module Extensions

    module CallbackSupport
      extend Includable

      class Manager
        attr_reader :map, :allowed

        def initialize allowed=[]
          @allowed = allowed
          @map ||= Hashie::Mash.new
        end

        def method_missing name, *args, &block
          return super unless block_given? && allowed.include?(name)

          map[name] ||= []
          map[name] << block
        end

        def notify name, *args
          raise "Not registered as valid callback: #{name}" unless allowed.include?(name)
          return unless map

          (map[name] || []).map do |block|
            block.call(*args)
          end
        end
      end

      def callbacks &block
        manager.instance_eval(&block)
      end

      def notify name, *args
        manager.notify(name, *args)
      end

      def manager
        raise 'No callbacks allowed' unless respond_to?(:allowed_callbacks)
        @manager ||= Manager.new(allowed_callbacks)
      end

      module ClassMethods
        def callbacks *args
          define_method :allowed_callbacks do
            args.flatten
          end
        end
      end
    end

  end

end
