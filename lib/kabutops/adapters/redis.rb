# -*- encoding : utf-8 -*-

module Kabutops

  module Adapters

    class Redis < DatabaseAdapter
      include Extensions::Parameterable

      params :host, :port, :namespace, :db, :password

      def store result
        client[result[:id]] = JSON.dump(result.to_hash)
      end

      def nested?
        true
      end

      protected

      def client
        @@client ||= ::Redis::Namespace.new(
          params[:namespace] || 'kabutops',
          redis: ::Redis.new(
            host: params[:host],
            port: params[:port],
            db: params[:db],
            password: params[:password],
          )
        )
      end
    end

  end

end
