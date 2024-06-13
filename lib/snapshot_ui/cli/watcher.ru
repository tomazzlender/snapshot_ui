# frozen_string_literal: true

require "async"
require "async/http/endpoint"
require "async/websocket/client"
require "async/websocket/adapters/rack"
require "listen"
require "set"

SNAPSHOT_DIRECTORY = ENV.fetch("SNAPSHOT_DIRECTORY")
WEBSOCKET_ENDPOINT = "http://localhost:7070/cable"

REFRESH_MESSAGE = {identifier: "{\"channel\":\"RefreshChannel\"}", message: "refresh"}.to_json
CONFIRM_SUBSCRIPTION_MESSAGE = {identifier: "{\"channel\":\"RefreshChannel\"}", type: "confirm_subscription"}.to_json
PING_MESSAGE = {type: "ping", message: Time.now.to_i.to_s}.to_json

@connections = Set.new

run lambda { |env|
  if env["REQUEST_PATH"] == "/cable"
    Async::WebSocket::Adapters::Rack.open(env, protocols: ["actioncable-v1-json"]) do |connection|
      @connections << connection

      Console.info "Client connected."
      connection.write(CONFIRM_SUBSCRIPTION_MESSAGE)
      connection.flush

      Async do |ping_task|
        loop do
          connection.write(PING_MESSAGE)
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
  endpoint = Async::HTTP::Endpoint.parse(WEBSOCKET_ENDPOINT)

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
  Pathname.new(SNAPSHOT_DIRECTORY).mkpath
  listener = Listen.to(SNAPSHOT_DIRECTORY) { |_modified, _added, _removed| broadcast_update }

  task.async do
    listener.start
    task.sleep
  end

  Console.info("Watching for snapshots updates in #{SNAPSHOT_DIRECTORY}...")
end

def broadcast_update
  @connections.each do |connection|
    connection.write(REFRESH_MESSAGE)
    connection.flush
  rescue => e
    Console.error "Failed to send message to client: #{e.message}"
  end
end
