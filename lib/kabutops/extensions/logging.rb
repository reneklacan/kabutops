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

          @@logger ||= Logger.new(STDOUT)
          #@@logger.level = Logger::WARN
        end

      end

    end

  end

end
