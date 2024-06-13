require "bundler/setup"
require "thor"
require "pathname"

module SnapshotUI
  class CLI < Thor
    WEBSOCKET_HOST = "localhost:7070"

    desc "watch SNAPSHOT_DIRECTORY", "Watches for snapshot changes in SNAPSHOT_DIRECTORY and broadcasts them on ws://#{WEBSOCKET_HOST}/cable."
    def watch(snapshot_directory)
      unless File.exist?(snapshot_directory)
        puts "The provided directory `#{snapshot_directory}` doesn't exist. Please double check the path."
        exit 1
      end

      websocket_host = "http://#{WEBSOCKET_HOST}"
      config_path = Pathname.new(__dir__).join("cli", "watcher.ru").cleanpath.to_s

      exec "SNAPSHOT_DIRECTORY=#{snapshot_directory} bundle exec falcon serve --bind #{websocket_host} --count 1 --config #{config_path}"
    end

    def self.exit_on_failure?
      true
    end
  end
end
