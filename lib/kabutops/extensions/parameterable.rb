# -*- encoding : utf-8 -*-

module Kabutops

  module Extensions

    module Parameterable

      def self.included base
        base.extend(ClassMethods)
      end

      module ClassMethods

        def params *list
          list.each do |name|
            define_method name do |*args|
              @params ||= Hashie::Mash.new
              if args.size == 1
                @params[name] = args[0]
              else
                @params[name] = args
              end
            end
          end

          define_method :params do
            @params ||= Hashie::Mash.new
          end
        end

      end

    end

  end

end
