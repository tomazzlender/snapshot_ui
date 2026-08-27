# frozen_string_literal: true

require_relative "lib/snapshot_ui/version"

Gem::Specification.new do |spec|
  spec.name = "snapshot_ui"
  spec.version = SnapshotUI::VERSION
  spec.authors = ["Tomaz Zlender"]
  spec.email = ["tomaz@zlender.se"]

  spec.summary = "Take snapshots of UI during testing for inspection in a browser."
  spec.homepage = "https://github.com/tomazzlender/snapshot_ui"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/main/gems/snapshot_ui"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/gems/snapshot_ui/CHANGELOG.md"

  gem_root = File.expand_path(__dir__)
  spec.files = Dir.chdir(gem_root) do
    Dir.glob(%w[lib/**/* snapshot_ui.gemspec README.md CHANGELOG.md LICENSE.txt]).select { |path| File.file?(path) }
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", ">= 2.2", "< 4"
end
