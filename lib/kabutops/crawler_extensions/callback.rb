module Kabutops

  module CrawlerExtensions

    module Callback

      def self.included base
        base.extend(ClassMethods)
      end

      module ClassMethods
        def callback &block
          adapter = Adapters::Callback.new(block)

          @adapters ||= []
          @adapters << adapter
        end
      end

    end

  end

end
