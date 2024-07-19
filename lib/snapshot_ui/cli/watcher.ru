# frozen_string_literal: true

require "async"
require "async/http/endpoint"
require "async/websocket/client"
require "async/websocket/adapters/rack"
require "listen"
require "set"
require "uri"

load ENV.fetch("SNAPSHOT_UI_INITIALIZER_FILE")

REFRESH_MESSAGE = {identifier: "{\"channel\":\"RefreshChannel\"}", message: "refresh"}.to_json
CONFIRM_SUBSCRIPTION_MESSAGE = {identifier: "{\"channel\":\"RefreshChannel\"}", type: "confirm_subscription"}.to_json

@connections = Set.new

live_websocket_uri = URI.parse(SnapshotUI.configuration.live_websocket_url)

run lambda { |env|
  if env["REQUEST_PATH"] == live_websocket_uri.path
    Async::WebSocket::Adapters::Rack.open(env, protocols: ["actioncable-v1-json"]) do |connection|
      @connections << connection

      Console.info "Client connected."
      connection.write(CONFIRM_SUBSCRIPTION_MESSAGE)
      connection.flush

      Async do |ping_task|
        loop do
          connection.write({type: "ping", message: Time.now.to_i.to_s}.to_json)
          connection.flush
          sleep(2)
        end
      ensure
        ping_task&.stop
      end

      while connection.read
      end
    rescue Protocol::WebSocket::ClosedError
      Console.info "Client disconnected."
      @connections.delete(connection)
    ensure
      Console.info "Client disconnected."
      @connections.delete(connection)
    end
  else
    [404, {}, ["404 Not Found"]]
  end
}

Async do |client_task|
  endpoint = Async::HTTP::Endpoint.parse(SnapshotUI.configuration.live_websocket_url)

  Async::WebSocket::Client.connect(endpoint) do |connection|
    Async do |listener_task|
      detect_snapshots_update(listener_task)
    end

    while (message = connection.read)
      if message == REFRESH_MESSAGE
        Console.info "Snapshots updated."
      end
    end
  ensure
    client_task&.stop
  end
end

def detect_snapshots_update(task)
  Pathname.new(SnapshotUI.configuration.storage_directory).mkpath
  listener = Listen.to(SnapshotUI.configuration.storage_directory) { |_modified, _added, _removed| broadcast_update }

  task.async do
    listener.start
    task.sleep
  end

  Console.info("Watching for snapshots updates in #{SnapshotUI.configuration.storage_directory}")
  Console.info("Review snapshots on #{SnapshotUI.configuration.web_url}")
end

def broadcast_update
  @connections.each do |connection|
    connection.write(REFRESH_MESSAGE)
    connection.flush
  rescue => e
    Console.error "Failed to send message to client: #{e.message}"
  end
end
