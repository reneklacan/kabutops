module Kabutops

  module CrawlerExtensions

    module Mysql

      def self.included base
        base.extend(ClassMethods)
      end

      module ClassMethods
        def mysql
          raise NotImplementedError
        end
      end

    end

  end

end
