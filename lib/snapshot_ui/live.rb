require "async"
require "set"
require_relative "live/server"
require_relative "live/listener"

module SnapshotUI
  module Live
    module_function

    def run(configuration)
      Async do
        websocket_connections = Set.new

        listener = Listener.new(websocket_connections, configuration)
        server = Server.new(websocket_connections, configuration)

        listener.run
        server.run.wait
      end
    end
  end
end
