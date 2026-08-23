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
end

def rails_available?
  Bundler.load.specs.map(&:name).include?("rails")
rescue Bundler::GemfileNotFound, Bundler::GemNotFound
  false
end

namespace :rails do
  desc "Run the snapshot_ui-rails tests (requires Rails in the bundle)"
  task :test do
    if rails_available?
      require "minitest/test_task"
      Minitest::TestTask.create(:rails_run) do |t|
        t.test_globs = %w[snapshot_ui-rails/test/**/*_test.rb]
        t.warning = false
      end
      Rake::Task["rails_run"].invoke
    else
      puts "Skipping snapshot_ui-rails tests: Rails is not in this bundle (BUNDLE_GEMFILE=)."
    end
  end
end

require "standard/rake"

task default: %i[test rails:test standard]

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

namespace :vendor do
  desc "Download the latest Turbo and Stimulus (or TURBO_VERSION / STIMULUS_VERSION) into the vendored assets"
  task :update do
    require "json"
    require "net/http"

    fetch = lambda do |url|
      response = Net::HTTP.get_response(URI(url))
      response = Net::HTTP.get_response(URI(response["location"])) while response.is_a?(Net::HTTPRedirection)
      raise "#{url}: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    {"turbo" => "@hotwired/turbo", "stimulus" => "@hotwired/stimulus"}.each do |name, package|
      version = ENV["#{name.upcase}_VERSION"] || JSON.parse(fetch.call("https://registry.npmjs.org/#{package}/latest"))["version"]
      manifest = JSON.parse(fetch.call("https://registry.npmjs.org/#{package}/#{version}"))
      source = fetch.call("https://cdn.jsdelivr.net/npm/#{package}@#{version}/#{manifest["module"]}")
      path = "lib/snapshot_ui/web/assets/javascripts/vendor/#{name}.js"

      File.write(path, "// #{package} #{version} (#{manifest["license"]}), vendored with `rake vendor:update`\n#{source}")
      puts "#{path}: #{package} #{version}"
    end
  end
end
