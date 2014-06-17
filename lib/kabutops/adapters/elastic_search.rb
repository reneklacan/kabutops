module Kabutops

  module Adapters

    class ElasticSearch < DatabaseAdapter
      include Parameterable

      params :host, :port, :index, :type

      def store result
        @@client ||= Elasticsearch::Client.new
        @@client.index(
          index: @params[:index] || 'default',
          type: @params[:type] || 'default',
          id: result[:id],
          body: result.to_hash,
        )
      end

      def nested?
        true
      end
    end

  end

end
