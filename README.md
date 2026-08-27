# Snapshot UI

Take snapshots of responses in integration tests and view them in a browser.

This repository develops two Ruby gems together:

- [`snapshot_ui`](gems/snapshot_ui) — the Rack-agnostic core, web interface, and minitest integration.
- [`snapshot_ui-rails`](gems/snapshot_ui-rails) — automatic Rails configuration, routing, test helpers, and mail snapshots.

## Development

```sh
bin/setup
bundle exec rake
```

Build and verify both packaged gems with:

```sh
bundle exec rake gems:verify
```

## Using an unreleased version

Because each gemspec lives below `gems/`, use Bundler's `glob:` option when installing directly from Git:

```ruby
gem "snapshot_ui",
  git: "https://github.com/tomazzlender/snapshot_ui",
  glob: "gems/snapshot_ui/*.gemspec"
```

For the Rails integration, let Bundler discover both the adapter and its local core dependency:

```ruby
gem "snapshot_ui-rails",
  git: "https://github.com/tomazzlender/snapshot_ui",
  glob: "gems/*/*.gemspec"
```

## License

Released under the [MIT License](LICENSE.txt).
