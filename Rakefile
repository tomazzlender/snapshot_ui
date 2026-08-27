# frozen_string_literal: true

require "bundler"
require "minitest/test_task"
require "tmpdir"
require_relative "gems/snapshot_ui/lib/snapshot_ui"

CORE_GEM_PATH = "gems/snapshot_ui"
RAILS_GEM_PATH = "gems/snapshot_ui-rails"
GEMSPEC_PATHS = ["#{CORE_GEM_PATH}/snapshot_ui.gemspec", "#{RAILS_GEM_PATH}/snapshot_ui-rails.gemspec"].freeze

Minitest::TestTask.create(:test) do |t|
  t.libs = [".", "#{CORE_GEM_PATH}/lib", "#{CORE_GEM_PATH}/test"]
  t.test_globs = ["#{CORE_GEM_PATH}/test/snapshot_ui/**/*_test.rb"]
end

namespace :dummy do
  Minitest::TestTask.create(:test) do |t|
    t.libs = [".", "#{CORE_GEM_PATH}/lib", "#{CORE_GEM_PATH}/test"]
    t.test_globs = ["#{CORE_GEM_PATH}/test/dummy/test/**/*_test.rb", "#{CORE_GEM_PATH}/test/dummy/test/**/*_spec.rb"]
  end

  desc "Start puma server for the dummy application"
  task :server do
    system "bundle exec puma #{CORE_GEM_PATH}/test/dummy/config.ru -p 3001"
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
        t.test_globs = ["#{RAILS_GEM_PATH}/test/**/*_test.rb"]
        t.warning = false
      end
      Rake::Task["rails_run"].invoke
    else
      puts "Skipping snapshot_ui-rails tests: Rails is not in this bundle (BUNDLE_GEMFILE=)."
    end
  end
end

namespace :gems do
  desc "Build all gems into pkg"
  task :build do
    mkdir_p "pkg"

    GEMSPEC_PATHS.each do |gemspec_path|
      spec = Gem::Specification.load(gemspec_path)
      output_path = File.expand_path("pkg/#{spec.full_name}.gem")

      Dir.chdir(File.dirname(gemspec_path)) do
        sh "gem", "build", File.basename(gemspec_path), "--strict", "--output", output_path
      end
    end
  end

  desc "Build, install, and load all packaged gems"
  task verify: :build do
    specs = GEMSPEC_PATHS.map { |path| Gem::Specification.load(path) }
    required_files = {
      "snapshot_ui" => %w[LICENSE.txt README.md lib/snapshot_ui.rb lib/snapshot_ui/web.rb lib/snapshot_ui/web/views/snapshots/show.html.erb],
      "snapshot_ui-rails" => %w[LICENSE.txt README.md lib/snapshot_ui-rails.rb lib/snapshot_ui/rails/railtie.rb lib/snapshot_ui/rails/web/views/snapshots/mail/show.html.erb]
    }

    specs.each do |spec|
      missing_files = required_files.fetch(spec.name) - spec.files
      abort "#{spec.name} package is missing: #{missing_files.join(", ")}" unless missing_files.empty?
    end

    Dir.mktmpdir("snapshot-ui-gems") do |gem_home|
      specs.each do |spec|
        sh "gem", "install", "pkg/#{spec.full_name}.gem", "--local", "--ignore-dependencies", "--no-document", "--install-dir", gem_home
      end

      load_paths = specs.map { |spec| File.join(gem_home, "gems", spec.full_name, "lib") }
      Bundler.with_unbundled_env do
        sh({"RUBYOPT" => load_paths.map { |path| "-I#{path}" }.join(" ")}, "ruby", "-e", 'require "rails"; require "snapshot_ui/web"; require "snapshot_ui-rails"; abort unless SnapshotUI::Rails::VERSION == SnapshotUI::VERSION')
      end
    end
  end
end

desc "Build all gems into pkg"
task build: "gems:build"

require "standard/rake"

task default: %i[test rails:test standard]

namespace :snapshot_ui do
  desc "Clear snapshots"
  task :clear_snapshots do
    SnapshotUI.configure do |config|
      config.storage_directory = "#{CORE_GEM_PATH}/test/dummy/tmp/snapshot_ui"
      config.project_root_directory = "#{CORE_GEM_PATH}/test/dummy"
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
      path = "#{CORE_GEM_PATH}/lib/snapshot_ui/web/assets/javascripts/vendor/#{name}.js"

      File.write(path, "// #{package} #{version} (#{manifest["license"]}), vendored with `rake vendor:update`\n#{source}")
      puts "#{path}: #{package} #{version}"
    end
  end
end
