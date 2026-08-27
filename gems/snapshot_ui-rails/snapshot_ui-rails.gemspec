# frozen_string_literal: true

require_relative "../snapshot_ui/lib/snapshot_ui/version"

Gem::Specification.new do |spec|
  spec.name = "snapshot_ui-rails"
  spec.version = SnapshotUI::VERSION
  spec.authors = ["Tomaz Zlender"]
  spec.email = ["tomaz@zlender.se"]

  spec.summary = "Rails integration for Snapshot UI — take snapshots of responses in tests and view them in a browser."
  spec.homepage = "https://github.com/tomazzlender/snapshot_ui"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/main/gems/snapshot_ui-rails"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/gems/snapshot_ui-rails/CHANGELOG.md"

  gem_root = File.expand_path(__dir__)
  spec.files = Dir.chdir(gem_root) do
    Dir.glob(%w[lib/**/* snapshot_ui-rails.gemspec README.md CHANGELOG.md LICENSE.txt]).select { |path| File.file?(path) }
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "snapshot_ui", SnapshotUI::VERSION
  spec.add_dependency "railties", ">= 7.1", "< 9"
end
