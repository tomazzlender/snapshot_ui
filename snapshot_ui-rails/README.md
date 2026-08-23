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

With the defaults, the whole setup is one line in your routes — **no initializer, no configuration**.

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
`/rails/mailers`.

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

### Snapshotting emails

`take_snapshot` also accepts an email, so you can review mailers in the browser instead of maintaining Action Mailer
previews:

```ruby
class NotifierMailerTest < ActionMailer::TestCase
  test "welcome email" do
    take_snapshot(NotifierMailer.welcome(user))

    assert_emails 0 # your usual assertions are unaffected
  end
end
```

One call captures the whole email. In the UI the snapshot shows:

* the subject, mailer/action and address headers, with the full header set one click away;
* **both the HTML and the plain-text versions** (a switcher appears when the email has both) — captured from the
  single message, so there is nothing to keep in sync;
* attachments, each downloadable, plus a **Download .eml** of the raw message.

`take_snapshot` accepts an `ActionMailer::MessageDelivery` (what a mailer action returns) or a `Mail::Message`, and
the same `title:` and `slug:` options as responses. It is available in `ActionMailer::TestCase` and in integration
tests with no explicit `include`.

### 3. Run the tests and view the snapshots

Snapshots are only taken when you ask for them, via the `--take-snapshots` flag or `TAKE_SNAPSHOTS=1`:

```sh
bin/rails test test/integration --take-snapshots
```

At the end of the run the URL to review the snapshots is printed. Start your app (`bin/rails server`) and open
<http://localhost:3000/rails/ui_snapshots>. The page refreshes automatically as you take new snapshots.

You'll usually want the snapshots directory ignored by git:

```
# .gitignore
/tmp/snapshot_ui/
```

## Configuration

**None is required.** Everything is inferred from the Rails application:

| Setting                  | Default                                                                          |
| ------------------------ | ------------------------------------------------------------------------------- |
| `project_root_directory` | `Rails.root`                                                                     |
| `storage_directory`      | `Rails.root/tmp/snapshot_ui`                                                     |
| `mount_path`             | `/rails/ui_snapshots`                                                            |
| `host`                   | the app's `default_url_options`, else `PORT`, else `http://localhost:3000`       |

The mount path and host are only used to build the "ready for review" URL printed after a test run and the link on the
UI's empty state; the interface itself works wherever it is mounted.

To override, add an initializer — it runs after this gem's defaults, so your values win:

```ruby
# config/initializers/snapshot_ui.rb
Rails.application.configure do
  # Mount somewhere other than /rails/ui_snapshots (also change the argument to mount_snapshot_ui):
  config.snapshot_ui.mount_path = "/admin/snapshots"

  # Only needed if your development server isn't on http://localhost:3000:
  config.snapshot_ui.host = "http://localhost:4000"
end
```

```ruby
# config/routes.rb — pass the same path when it isn't the default
mount_snapshot_ui at: "/admin/snapshots" if Rails.env.development?
```

If you already set `config.action_controller.default_url_options`, the host is taken from there and you don't need to
set `config.snapshot_ui.host` at all.

## How it works

The gem is a thin adapter over `snapshot_ui`. A Railtie:

* fills in `SnapshotUI.configuration` from `Rails.root`, the mount path and the resolved host;
* requires the `mount_snapshot_ui` router helper, which mounts the same `SnapshotUI::Web` Rack app the core gem ships;
* includes `SnapshotUI::Test::MinitestHelpers` into `ActionDispatch::IntegrationTest` via `ActiveSupport.on_load`.

For anything not specific to Rails, see the [Snapshot UI README](https://github.com/tomazzlender/snapshot_ui).

## License

MIT.
