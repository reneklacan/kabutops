# -*- encoding : utf-8 -*-

module Kabutops

  module Adapters

    class Sequel < DatabaseAdapter
      include Extensions::Parameterable

      params :connect, :type, :host, :port,
             :db, :user, :password, :table

      def store result
        client_table.insert(result)
      end

      def nested?
        false
      end

      protected

      def client
        return @@client if defined?(@@client)

        if params[:connect]
          @@client ||= ::Sequel.connect(params[:connect])
        else
          @@client ||= ::Sequel.connect(
            adapter: params[:type] || 'mysql2',
            user: params[:user] || 'root',
            password: params[:password] || 'root',
            host: params[:host] || 'localhost',
            port: params[:port] || 3306,
            database: params[:db] || params[:database] || 'kabutops',
          )
        end
      end

      def client_table
        @@client_table ||= client[params[:table]]
      end
    end

  end

end
