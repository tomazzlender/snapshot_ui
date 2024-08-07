# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"
require_relative "lib/snapshot_ui"

Minitest::TestTask.create(:test) do |t|
  t.test_globs = %w[test/snapshot_ui/**/*_test.rb]
end

namespace :dummy do
  Minitest::TestTask.create(:test) do |t|
    t.test_globs = %w[test/dummy/test/**/*_test.rb test/dummy/test/**/*_spec.rb]
  end

  desc "Start puma server for the dummy application"
  task :server do
    system "bundle exec puma test/dummy/config.ru -p 3001"
  end

  desc "Start server for broadcasting live updates of snapshots"
  task :live do
    system "bundle exec snapshot_ui live test/dummy/config/snapshot_ui_initializer.rb"
  end
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
