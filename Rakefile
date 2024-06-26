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
