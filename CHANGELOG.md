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
- Development dependencies updated; CI runs on Ruby 3.2 to 4.0 with both minitest 5 and 6.

## [0.1.0] - 2024-06-09

- Initial release
