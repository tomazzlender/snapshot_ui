# frozen_string_literal: true

require_relative "snapshot_ui/snapshot"
require_relative "snapshot_ui/configuration"

module SnapshotUI
  DEFAULT_CONFIGURATION = {
    project_root_directory: ".",
    storage_directory: "tmp/snapshot_ui"
  }.freeze

  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new(**DEFAULT_CONFIGURATION)
  end

  def self.publish_snapshots_in_progress
    Snapshot.publish_snapshots_in_progress
  end

  def self.clear_snapshots_in_progress
    Snapshot.clear_snapshots_in_progress
  end

  def self.clear_snapshots
    Snapshot.clear_snapshots
  end
end
