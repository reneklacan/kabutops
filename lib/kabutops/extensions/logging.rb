module Kabutops

  module Extensions

    module Logging
      extend Includable

      def logger
        self.class.logger
      end

      module ClassMethods

        def logger
          return @@logger if defined?(@@logger)

          @@logger = Logger.new(Configuration[:logger][:dev])
          @@logger.level = Configuration[:logger][:level]
          @@logger
        end

      end

    end

  end

end
