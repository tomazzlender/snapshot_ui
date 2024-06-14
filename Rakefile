# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"
require_relative "lib/snapshot_ui"

Minitest::TestTask.create

require "standard/rake"

task default: %i[test standard]

namespace :snapshot_ui do
  desc "Clear snapshots"
  task :clear_snapshots do
    SnapshotUI.clear_snapshots
  end
end

return unless SnapshotUI.snapshot_taking_enabled?

SnapshotUI.configure do |config|
  config.storage_directory = "#{File.expand_path(__dir__)}/test/dummy/tmp/snapshot_ui"
  config.project_root_directory = "#{File.expand_path(__dir__)}/test/dummy"
end

namespace :snapshot_ui do
  desc "Clear snapshots in progress, needs to be invoked before tests."
  task :clear_snapshots_in_progress do
    SnapshotUI.clear_snapshots_in_progress
  end

  desc "Publish snapshots in progress, needs to be invoked after tests. It moves snapshots from `in_progress` to `snapshots` directories."
  task :publish_snapshots_in_progress do
    SnapshotUI.publish_snapshots_in_progress

    puts "\nUI snapshots are ready for review on http://localhost:3001/ui/snapshots."
  end
end

Rake::Task["test"].enhance(["snapshot_ui:clear_snapshots_in_progress"])
Rake::Task["test"].enhance do
  Rake::Task["snapshot_ui:publish_snapshots_in_progress"].invoke
end
