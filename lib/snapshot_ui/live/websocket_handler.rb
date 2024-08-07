require "uri"
require "async/websocket/adapters/rack"
require_relative "websocket_message"

module SnapshotUI
  module Live
    class WebsocketHandler
      WEBSOCKET_PROTOCOL = "actioncable-v1-json"

      def initialize(connections, configuration)
        @connections = connections
        @configuration = configuration
      end

      def call(env)
        live_websocket_uri = URI.parse(@configuration.live_websocket_url)

        if env["REQUEST_PATH"] == live_websocket_uri.path
          Async::WebSocket::Adapters::Rack.open(env, protocols: [WEBSOCKET_PROTOCOL]) do |connection|
            @connections << connection

            send_confirmation_message(connection)
            send_ping_periodically(connection)

            while connection.read; end
          rescue Protocol::WebSocket::ClosedError, EOFError
            @connections.delete(connection)
          ensure
            @connections.delete(connection)
          end
        else
          [404, {}, ["WebSocket connections are accepted at the endpoint: #{@configuration.live_websocket_url}"]]
        end
      end

      def send_confirmation_message(connection)
        connection.write(WebsocketMessage.confirm_subscription)
        connection.flush
      end

      def send_ping_periodically(connection)
        Async do |ping_task|
          loop do
            connection.write(WebsocketMessage.ping)
            connection.flush
            sleep(2)
          end
        ensure
          ping_task&.stop
        end
      end
    end
  end
end
