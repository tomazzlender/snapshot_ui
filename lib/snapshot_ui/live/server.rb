require "async/http/endpoint"
require "falcon"
require_relative "websocket_handler"

module SnapshotUI
  module Live
    class Server
      def initialize(websocket_connections, configuration)
        endpoint = Async::HTTP::Endpoint.parse(configuration.live_websocket_url)
        middleware = Falcon::Server.middleware(WebsocketHandler.new(websocket_connections, configuration))
        @server = Falcon::Server.new(middleware, endpoint)
      end

      def run
        @server.run
      end
    end
  end
end
