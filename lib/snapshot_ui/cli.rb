require "bundler/setup"
require "thor"
require_relative "live"

module SnapshotUI
  class CLI < Thor
    desc "live SNAPSHOT_UI_CONFIG_FILE_PATH", "Run the command to enable live refreshing of UI snapshots."
    def live(config_file_path)
      exit_command(config_file_path) unless File.exist?(config_file_path)

      load config_file_path
      Live.run(SnapshotUI.configuration)
    end

    def self.exit_on_failure?
      true
    end

    private

    def exit_command(config_file_path)
      puts "The provided config file `#{config_file_path}` doesn't exist. Please double check the path."
      exit 1
    end
  end
end
