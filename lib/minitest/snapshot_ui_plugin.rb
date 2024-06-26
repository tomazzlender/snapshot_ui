require "snapshot_ui"
require "minitest"

module Minitest
  class << self
    def plugin_snapshot_ui_options(opts, _options)
      opts.on "--take-snapshots", "Take UI snapshots" do
        ENV["TAKE_SNAPSHOTS"] = "true"
      end
    end

    def plugin_snapshot_ui_init(_options)
      return unless SnapshotUI.snapshot_taking_enabled?

      SnapshotUI.exit_if_not_configured!

      reporter << SnapshotUIReporter.new

      SnapshotUI.clear_snapshots_in_progress
    end
  end

  class SnapshotUIReporter < Reporter
    def report
      SnapshotUI.publish_snapshots_in_progress

      io.print "\n\nUI snapshots are ready for review at #{SnapshotUI.configuration.web_url}"
    end
  end
end
