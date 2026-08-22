require "snapshot_ui"
require "minitest"

module Minitest
  class << self
    def plugin_snapshot_ui_options(opts, _options)
      return if opts.top.long.key?("take-snapshots")

      opts.on "--take-snapshots", "Take UI snapshots" do
        ENV["TAKE_SNAPSHOTS"] = "true"
      end
    end

    def plugin_snapshot_ui_init(_options)
      return unless SnapshotUI.snapshot_taking_enabled?
      # Minitest may list this plugin twice: registered below and discovered on its
      # own (minitest 5) or loaded with `Minitest.load :snapshot_ui`. Set up once.
      return if reporter.reporters.any? { |other| other.is_a?(SnapshotUIReporter) }

      SnapshotUI.exit_if_not_configured!

      reporter << SnapshotUIReporter.new

      SnapshotUI.clear_snapshots_in_progress
    end
  end

  class SnapshotUIReporter < Reporter
    def report
      SnapshotUI.publish_snapshots_in_progress

      io.puts "\n\nUI snapshots are ready for review at #{SnapshotUI.configuration.web_url}"
    end
  end
end

# Minitest 6 no longer discovers plugins on its own: requiring this file, which
# `snapshot_ui/test/minitest_helpers` does, is what opts in.
Minitest.register_plugin :snapshot_ui if Minitest.respond_to?(:register_plugin)
