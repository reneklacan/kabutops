module Kabutops

  module Extensions

    module Parameterable

      def self.included base
        base.extend(ClassMethods)
        base.class_eval do
          attr_reader :params
        end
      end

      module ClassMethods

        def params *list
          return @params if list.empty?

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
        end

      end

    end

  end

end
