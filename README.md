# Snapshot UI

Take snapshots of responses in integration tests, and display them in a browser.

Works with any kind of Rack application and minitest testing framework.

**Using Rails?** The [`snapshot_ui-rails`](snapshot_ui-rails) gem wires Snapshot UI into Rails so it works out of the
box — no configuration, a `mount_snapshot_ui` route helper, and `take_snapshot` available in integration tests.

> ℹ️ The Snapshot UI is the next generation of a similar library, [Snapshot Inspector](https://github.com/tomazzlender/snapshot_inspector).
> It works with any kind of Rack application, not just Rails applications. Future development will take place here, and Snapshot Inspector will be eventually archived.
