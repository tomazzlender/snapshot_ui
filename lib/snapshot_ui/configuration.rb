# frozen_string_literal: true

require_relative "colorize"

module SnapshotUI
  class Configuration
    attr_writer :storage_directory, :project_root_directory
    attr_accessor :web_url

    def initialize(project_root_directory:, storage_directory:, web_url:)
      @project_root_directory = project_root_directory
      @storage_directory = storage_directory
      @web_url = web_url
    end

    def storage_directory
      Pathname.new(@storage_directory) if @storage_directory
    end

    def project_root_directory
      Pathname.new(@project_root_directory) if @project_root_directory
    end

    # Live updates no longer need a separate WebSocket server: the web UI polls
    # for changes instead. Kept so that existing configuration files keep working.
    def live_websocket_url=(_value)
      warn(
        "[snapshot_ui] `config.live_websocket_url` is deprecated and has no effect: " \
        "the web UI now polls for snapshot updates. Remove it from your configuration.",
        uplevel: 1
      )
    end

    def exit_if_not_configured!
      return unless project_root_directory.nil? || storage_directory.nil? || web_url.nil?

      puts Colorize.red("Looks like SnapshotUI is not configured yet. Example configuration:\n")

      puts <<~CONFIG
        #{Colorize.green("SnapshotUI.configure do |config|")}
          #{Colorize.green('config.storage_directory = "/path/to/tmp/snapshot_ui"')} #{Colorize.red("# Current value is `#{storage_directory.inspect}`")}
          #{Colorize.green('config.project_root_directory = "/path/to/project/root"')} #{Colorize.red("# Current value is `#{project_root_directory.inspect}`")}
          #{Colorize.green("config.web_url = \"#{web_url}\"")} #{Colorize.red("# Current value is `#{web_url.inspect}`")}
        #{Colorize.green("end")}

      CONFIG

      raise SystemExit.new(1)
    end
  end
end
