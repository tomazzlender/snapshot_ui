## [Unreleased]

- Initial release. Rails integration for Snapshot UI:
  - Snapshot UI is configured automatically from the Rails application (root, tmp directory, mount path and host);
    with the defaults no initializer is required.
  - The URL shown after a test run is derived from `config.snapshot_ui.mount_path` and `config.snapshot_ui.host`
    (the host defaults from the app's `default_url_options`, then `PORT`, then `http://localhost:3000`).
  - `mount_snapshot_ui` mounts the web interface in `config/routes.rb`; the default path is `/rails/ui_snapshots`.
  - `take_snapshot` is available in `ActionDispatch::IntegrationTest` without an explicit `include`.
