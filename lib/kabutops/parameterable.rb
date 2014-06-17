module Kabutops

  module Parameterable

    def self.included base
      base.extend(ClassMethods)
    end

    module ClassMethods

      def params *args
        return @params if args.empty?

        args.each do |name|
          define_method name do |value|
            @params ||= Hashie::Mash.new
            @params[name] = value
          end
        end
      end

    end

  end

end
