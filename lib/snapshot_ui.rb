# frozen_string_literal: true

require_relative "snapshot_ui/snapshot"
require_relative "snapshot_ui/configuration"

module SnapshotUI
  DEFAULT_CONFIGURATION = {
    project_root_directory: nil,
    storage_directory: nil,
    web_url: "http://localhost:3000/ui/snapshots"
  }.freeze

  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new(**DEFAULT_CONFIGURATION)
  end

  def self.snapshot_taking_enabled?
    %w[1 true].include?(ENV["TAKE_SNAPSHOTS"])
  end

  def self.publish_snapshots_in_progress
    exit_if_not_configured!

    Snapshot.publish_snapshots_in_progress
  end

  def self.clear_snapshots_in_progress
    exit_if_not_configured!

    Snapshot.clear_snapshots_in_progress
  end

  def self.clear_snapshots
    exit_if_not_configured!

    Snapshot.clear_snapshots
  end

  def self.exit_if_not_configured!
    configuration.exit_if_not_configured!
  end
end
