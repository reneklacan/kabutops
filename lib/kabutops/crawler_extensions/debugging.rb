module Kabutops

  module CrawlerExtensions

    module Debugging

      def self.included base
        base.extend(ClassMethods)
      end

      module ClassMethods

        def debug_first count=1
          params[:collection].take(count).each{ |r| debug_resource(r) }
        end

        def debug_random count=1
          params[:collection].sample(count).each{ |r| debug_resource(r) }
        end

        def debug_resource resource
          enable_debug
          self.new.perform(resource)
        end

        def enable_debug
          @adapters.each { |a| a.enable_debug }
        end

      end

    end

  end

end
