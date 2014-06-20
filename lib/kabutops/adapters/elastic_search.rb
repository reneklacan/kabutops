# -*- encoding : utf-8 -*-

module Kabutops

  module Adapters

    class ElasticSearch < DatabaseAdapter
      include Extensions::Parameterable

      params :host, :port, :index, :type

      def store result
        client.index(
          index: params[:index] || 'default',
          type: params[:type] || 'default',
          id: result[:id],
          body: result.to_hash,
        )
      end

      def nested?
        true
      end

      protected

      def client
        @@client ||= Elasticsearch::Client.new(
          hosts: [
            {
              host: params[:host] || 'localhost',
              port: params[:port] || '9200',
            },
          ],
        )
      end
    end

  end

end
