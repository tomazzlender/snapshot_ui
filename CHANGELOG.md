## [Unreleased]

- Live updates no longer need the `snapshot_ui live` command or a separate WebSocket server. The web UI polls a new
  `version` endpoint (`<mount path>/version`, e.g. `/ui/snapshots/version`) once a second and refreshes the page
  through Turbo when the published snapshots change.
- Removed the `snapshot_ui` executable. Setting `config.live_websocket_url` now prints a deprecation warning and has
  no effect.
- Dropped the `falcon`, `async-websocket`, `listen` and `thor` dependencies, as well as the ActionCable JavaScript.
- Turbo and Stimulus are now bundled with the gem instead of being loaded from a CDN, so the web UI works offline.
- Publishing snapshots moves the previous ones aside instead of deleting them first, so the list of snapshots is never
  briefly empty while a test run finishes.
- Fixed `NoMethodError: undefined method 'rmtree'` on Ruby 4.0 by requiring `pathname` explicitly.
- Works with minitest 6, which no longer discovers plugins on its own: requiring `snapshot_ui/test/minitest_helpers`
  now registers the minitest plugin, so `--take-snapshots` and publishing at the end of a run keep working
  (`Minitest.load :snapshot_ui` works as well).
- Development dependencies updated; CI runs on Ruby 3.3 to 4.0 with both minitest 5 and 6.
- Requires Ruby 3.3 or newer.
- Works with Rack 2.2 as well as Rack 3, so it can be used in Rails 6.1 and 7.0 applications.
- Terminal colours are only used when writing to a terminal, and not when `NO_COLOR` is set.
- Snapshot files no longer record the class of the object passed to `take_snapshot`; it was never used.
- `rake vendor:update` downloads the latest Turbo and Stimulus into the gem.
- Pages for snapshots that can't be found respond with 404 instead of 200.
- The Rack application serving the UI is built once instead of on every request.
- A malformed snapshot file, or a URL whose slug would point outside the snapshots directory, now renders the not-found page instead of raising a 500 or reading an arbitrary file.

## [0.1.0] - 2024-06-09

- Initial release
