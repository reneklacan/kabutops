module Kabutops

  module Adapters

    class MySQL < DatabaseAdapter
      include Parameterable

      params :host, :port, :database, :user, :password, :table

      def nested?
        false
      end
    end

  end

end
