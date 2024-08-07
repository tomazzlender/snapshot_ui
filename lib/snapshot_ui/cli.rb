require "bundler/setup"
require "thor"
require "pathname"
require "uri"

module SnapshotUI
  class CLI < Thor
    desc "live SNAPSHOT_UI_CONFIG_FILE_PATH", "Run the command to enable live refreshing of UI snapshots."
    def live(initializer_file)
      unless File.exist?(initializer_file)
        puts "The provided initializer file `#{initializer_file}` doesn't exist. Please double check the path."
        exit 1
      end

      load initializer_file

      websocket_host_uri = URI.parse(SnapshotUI.configuration.live_websocket_url)
      websocket_host_uri.path = ""

      config_path = Pathname.new(__dir__).join("cli", "watcher.ru").cleanpath.to_s

      exec "SNAPSHOT_UI_INITIALIZER_FILE=#{initializer_file} bundle exec falcon serve --bind #{websocket_host_uri} --count 1 --config #{config_path}"
    end

    def self.exit_on_failure?
      true
    end
  end
end
