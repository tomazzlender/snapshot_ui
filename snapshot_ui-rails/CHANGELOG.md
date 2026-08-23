## [Unreleased]

- Initial release. Rails integration for Snapshot UI:
  - Snapshot UI is configured automatically from the Rails application (root, tmp directory and mount path); no
    initializer is required.
  - `mount_snapshot_ui` mounts the web interface in `config/routes.rb`; the default path is `/rails/ui_snapshots`.
  - `take_snapshot` is available in `ActionDispatch::IntegrationTest` without an explicit `include`.
