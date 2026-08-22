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
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = (`git ls-files | grep -E '^(lib)'`.split("\n") + %w[snapshot_ui.gemspec README.md CHANGELOG.md LICENSE.txt])
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "rack", ">= 2.2", "< 4"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
