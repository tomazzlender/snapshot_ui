# Snapshot UI for Rails

Rails integration for [Snapshot UI](https://github.com/tomazzlender/snapshot_ui). Take snapshots of responses in your
integration tests and view them in a browser — with no configuration.

This gem wires Snapshot UI into a Rails application: it fills in Snapshot UI's configuration from what Rails already
knows, adds a router helper to mount the web interface, and makes `take_snapshot` available in your integration tests.

## Installation

```ruby
# Gemfile
group :development, :test do
  gem "snapshot_ui-rails"
end
```

```sh
bundle install
```

The `snapshot_ui` gem is pulled in automatically.

## Usage

### 1. Mount the web interface

Snapshot UI is a development tool: it displays artifacts captured during test runs and has nothing to show in
production. Mount it only where you need it, the way you would Sidekiq's or Flipper's dashboards:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount_snapshot_ui if Rails.env.development?
  # ...
end
```

This mounts the UI at `/rails/ui_snapshots` — alongside Rails' own development tools such as `/rails/info` and
`/rails/mailers`. To mount it elsewhere:

```ruby
mount_snapshot_ui at: "/admin/snapshots"
```

If you take snapshots in your `test` environment and review them by booting a `development` server against the same
`tmp` directory (the usual setup), the development-only guard above is all you need. Adjust the condition if your
workflow differs.

### 2. Take snapshots in your integration tests

`take_snapshot` is available in every `ActionDispatch::IntegrationTest` — no `include` required:

```ruby
require "test_helper"

class GreetingsTest < ActionDispatch::IntegrationTest
  test "the greeting page" do
    get "/hello"

    take_snapshot(response)

    assert_response :success
  end
end
```

`take_snapshot` accepts an object that responds to `#body` (such as the integration test's `response`) or a plain
`String`, and two options:

```ruby
take_snapshot(response, title: "The greeting", slug: "greeting")
```

* `title` — the name shown in the list (defaults to a name derived from the test).
* `slug` — a custom, stable URL for the snapshot (`/rails/ui_snapshots/greeting`); must be unique.

### 3. Run the tests and view the snapshots

Snapshots are only taken when you ask for them, via the `--take-snapshots` flag or `TAKE_SNAPSHOTS=1`:

```sh
bin/rails test test/integration --take-snapshots
```

At the end of the run the URL to review the snapshots is printed. Start your app (`bin/rails server`) and open
<http://localhost:3000/rails/ui_snapshots>. The page refreshes automatically as you take new snapshots.

## Configuration

Everything is inferred from the Rails application, so no initializer is needed. The defaults:

| Setting                   | Default                                          |
| ------------------------- | ------------------------------------------------ |
| `project_root_directory`  | `Rails.root`                                     |
| `storage_directory`       | `Rails.root/tmp/snapshot_ui`                     |
| mount path / `web_url`    | `/rails/ui_snapshots` on `http://localhost:3000` |

To override, set them under `config.snapshot_ui` (in `config/application.rb` or an environment file), or configure
`snapshot_ui` directly in an initializer — both run after this gem's defaults:

```ruby
# config/application.rb
config.snapshot_ui.mount_path = "/admin/snapshots"
config.snapshot_ui.web_url = "http://localhost:4000/admin/snapshots"
```

You'll usually want `tmp/snapshot_ui` ignored by git:

```
# .gitignore
/tmp/snapshot_ui/
```

## How it works

The gem is a thin adapter over `snapshot_ui`. A Railtie:

* fills in `SnapshotUI.configuration` from `Rails.root` and the mount path;
* requires the `mount_snapshot_ui` router helper, which mounts the same `SnapshotUI::Web` Rack app the core gem ships;
* includes `SnapshotUI::Test::MinitestHelpers` into `ActionDispatch::IntegrationTest` via `ActiveSupport.on_load`.

For anything not specific to Rails, see the [Snapshot UI README](https://github.com/tomazzlender/snapshot_ui).

## License

MIT.
