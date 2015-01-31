# -*- encoding : utf-8 -*-

module Kabutops

  module CrawlerExtensions

    module Debugging
      extend Extensions::Includable

      module ClassMethods
        def debug_first count=1
          params[:collection].take(count).map{ |r| debug_resource(r) }
        end

        def debug_random count=1
          params[:collection].sample(count).map{ |r| debug_resource(r) }
        end

        def debug_last count=1
          params[:collection].reverse.take(count).map{ |r| debug_resource(r) }
        end

        def debug_all
          params[:collection].map{ |r| debug_resource(r) }
        end

        def debug_resource resource
          enable_debug
          self.new.perform(resource)
        end

        def enable_debug
          @debug = true
          adapters.each { |a| a.enable_debug }
        end

        def debug
          @debug == true
        end
      end
    end

  end

end
