# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"
require_relative "lib/snapshot_ui"

Minitest::TestTask.create("test") do |t|
  t.test_globs = %w[test/snapshot_ui/**/*_test.rb]
end

Minitest::TestTask.create("dummy:test") do |t|
  t.test_globs = %w[test/dummy/test/**/*_test.rb test/dummy/test/**/*_spec.rb]
end

require "standard/rake"

task default: %i[test standard]

namespace :snapshot_ui do
  desc "Clear snapshots"
  task :clear_snapshots do
    SnapshotUI.configure do |config|
      config.storage_directory = "test/dummy/tmp/snapshot_ui"
      config.project_root_directory = "test/dummy"
      config.web_url = "http://localhost:3001/ui/snapshots"
    end

    SnapshotUI.clear_snapshots

    puts "✅  Snapshots cleared."
  end
end
