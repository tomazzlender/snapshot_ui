require "async"
require "async/http/endpoint"
require "async/websocket/client"
require "listen"
require "console"
require_relative "websocket_message"

module SnapshotUI
  module Live
    class Listener
      def initialize(websocket_connections, configuration)
        @configuration = configuration
        @websocket_connections = websocket_connections
      end

      def run
        Async do |client_task|
          endpoint = Async::HTTP::Endpoint.parse(@configuration.live_websocket_url)

          Async::WebSocket::Client.connect(endpoint) do |client_connection|
            Async do |listener_task|
              detect_snapshot_updates(listener_task)
            end

            while (message = client_connection.read)
              if message == WebsocketMessage.refresh
                Console.info "Snapshots updated."
              end
            end
          rescue Errno::ECONNREFUSED
            Console.info "Errno::ECONNREFUSED"
          ensure
            client_task&.stop
          end
        end
      end

      private

      def detect_snapshot_updates(task)
        ensure_storage_directory_exists

        listener =
          Listen.to(@configuration.storage_directory) do |_modified, _added, _removed|
            broadcast_update(@websocket_connections)
          end

        task.async do
          listener.start
          task.sleep
        end

        Console.info("Live updates activated for snapshots in #{@configuration.storage_directory}")
        Console.info("Start your application and visit #{@configuration.web_url}")
      end

      def broadcast_update(websocket_connections)
        websocket_connections.each do |websocket_connection|
          websocket_connection.write(WebsocketMessage.refresh)
          websocket_connection.flush
        rescue => error
          Console.error "Failed to send message to a client: #{error.message}"
        end
      end

      def ensure_storage_directory_exists
        Pathname.new(@configuration.storage_directory).mkpath
      end
    end
  end
end
