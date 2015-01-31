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

      def find resource
        result = client.search(
          index: params[:index] || 'default',
          body: {
            query: {
              filtered: {
                filter: {
                  or: [
                    { term: { id: resource[:id] || resource[:url] } },
                    { term: { url: resource[:url] } },
                  ]
                },
              },
            },
          },
          size: 5,
        )
        result['hits']['hits'].map{ |hit| hit['_source'] }.first
      end

      def find_outdated freshness
        result = client.search(
          index: params[:index] || 'default',
          body: {
            query: {
              filtered: {
                filter: {
                  and: [
                    {
                      or: [
                        { range: { updated_at: { lte: Time.now.to_i - freshness } } },
                        { missing: { field: 'updated_at' } },
                      ]
                    },
                    {
                      or: [
                        { range: { scheduled_update_at: { lte: Time.now.to_i - 3600 } } },
                        { missing: { field: 'scheduled_update_at' } },
                      ]
                    },
                  ]
                },
              },
            },
          },
          size: 5,
        )
        result['hits']['hits'].map{ |hit| hit['_source'] }
      end

      def client
        @client ||= Elasticsearch::Client.new(
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
