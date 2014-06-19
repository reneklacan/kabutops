# -*- encoding : utf-8 -*-

module Fakes

  class FakeCrawler
    class << self
      def params
        {
          collection: (1..100).map{ |id|
            {
              id: id,
              url: "http://example.com/#{id}",
            }
          },
        }
      end

      def adapters
        @adapters ||= 5.times.map{ FakeAdapter.new }
      end
    end

    def perform resource
      resource
    end
  end

end
