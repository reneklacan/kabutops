# -*- encoding : utf-8 -*-

module Kabutops

  class Configuration
    class << self
      def config *args, &block
        configuration.instance_eval &block
      end

      def [] key
        configuration[key]
      end

      def []= key, value
        configuration[key] = value
      end

      protected

      def configuration
        @configuration ||= Hashie::Mash.new(
          logger: {
            dev: STDOUT,
            level: Logger::DEBUG
          },
        )
      end
    end
  end

end
