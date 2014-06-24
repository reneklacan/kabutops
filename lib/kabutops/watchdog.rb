module Kabutops
  class Watchdog
    include Extensions::Logging
    include Sidekiq::Worker

    class << self
      include Extensions::Parameterable
      include Extensions::CallbackSupport

      params :crawler, :freshness, :wait
      callbacks :on_outdated

      def check!
        perform_async
      end

      def check
        new.check
      end

      def loop
        loop do
          sleep self.params[:wait] || 5
          check
        end
      end
    end

    def check
      logger.info "#{self.class} check started"

      outdated_resources.each do |resource|
        resource.update(scheduled_update_at: Time.now.to_i)

        adapters.each do |adapter|
          adapter.store(resource)
        end

        self.class.notify(:on_outdated, resource)
      end

      logger.info "#{self.class} check finished"
    end

    def perform
      check
      sleep self.class.params[:wait] || 5
      self.class.perform_async
    end

    protected

    def outdated_resources
      adapters.map{ |a| a.find_outdated(freshness) }
        .flatten
        .uniq
        .reject{ |r| (r[:scheduled_update_at] || 0) > Time.now.to_i - 3600 }
        .map{ |r| Hashie::Mash.new(r) }
    end

    def adapters
      self.class.params.crawler.adapters
    end

    def freshness
      self.class.params.freshness
    end
  end
end
