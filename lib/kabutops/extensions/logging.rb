module Kabutops

  module Extensions

    module Logging

      def self.included base
        base.extend(ClassMethods)
      end

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
