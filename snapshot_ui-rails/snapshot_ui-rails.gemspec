# frozen_string_literal: true

require_relative "lib/snapshot_ui/rails/version"

Gem::Specification.new do |spec|
  spec.name = "snapshot_ui-rails"
  spec.version = SnapshotUI::Rails::VERSION
  spec.authors = ["Tomaz Zlender"]
  spec.email = ["tomaz@zlender.se"]

  spec.summary = "Rails integration for Snapshot UI — take snapshots of responses in tests and view them in a browser."
  spec.homepage = "https://github.com/tomazzlender/snapshot_ui"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/snapshot_ui-rails/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    (`git ls-files -z lib`.split("\x0") + %w[snapshot_ui-rails.gemspec README.md CHANGELOG.md])
      .select { |path| File.exist?(File.join(__dir__, path)) }
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "snapshot_ui", SnapshotUI::Rails::VERSION
  spec.add_dependency "railties", ">= 7.1", "< 9"
end
