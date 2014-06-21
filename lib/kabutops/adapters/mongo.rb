# -*- encoding : utf-8 -*-

module Kabutops

  module Adapters

    class Mongo < DatabaseAdapter
      include Extensions::Parameterable

      params :host, :port, :db, :collection, :user, :password

      def store result
        existing = collection.find('id' => result[:id])

        if existing.count > 0
          existing.each do |document|
            collection.update({'_id' => document['_id']}, result.to_hash)
          end
        else
          collection.insert(result.to_hash)
        end
      end

      def nested?
        true
      end

      protected

      def client
        @@client ||= ::Mongo::MongoClient.new(
          params[:host] || 'localhost',
          params[:port] || 27017,
        )
      end

      def client_db
        @@client_db ||= client.db(params[:db].to_s || 'kabutops')
        if params[:user] && params[:password]
          ok = @@client.authenticate(params[:user], params[:password])
          raise 'mongo authentication failed' unless ok
        end
        @@client_db
      end

      def collection
        @@collection ||= client_db.collection(params[:collection] || 'kabutops')
      end
    end

  end

end
