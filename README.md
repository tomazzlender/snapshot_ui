# Snapshot UI

Take snapshots of responses in your integration tests and view them in a browser.

When a test makes a request, add `take_snapshot` and Snapshot UI saves the response. Run your tests with snapshots
enabled, then open the web interface to see exactly what each response rendered — useful for reviewing pages, emails,
or API payloads produced during testing. Snapshots are only captured when you ask for them, so normal test runs are
unaffected.

Works with any Rack application and the minitest testing framework.

**Using Rails?** The [`snapshot_ui-rails`](snapshot_ui-rails) gem wires all of this into Rails so it works out of the
box — no configuration, a `mount_snapshot_ui` route helper, and `take_snapshot` available in integration tests. If
you're on Rails, read that gem's README instead; the rest of this one describes the plain-Rack setup it builds on.

## Installation

```ruby
# Gemfile
group :development, :test do
  gem "snapshot_ui"
end
```

```sh
bundle install
```

## Setup

### 1. Configure

Tell Snapshot UI where your project lives, where to store snapshots, and the URL the web interface is served at:

```ruby
# e.g. config/snapshot_ui.rb, loaded by your app and your tests
require "snapshot_ui"

SnapshotUI.configure do |config|
  config.storage_directory = File.expand_path("tmp/snapshot_ui", __dir__)
  config.project_root_directory = File.expand_path(".", __dir__)
  config.web_url = "http://localhost:3000/ui/snapshots"
end
```

| Setting                  | What it is                                                                  |
| ------------------------ | -------------------------------------------------------------------------- |
| `storage_directory`      | Where snapshot files are written (put it under `tmp`).                     |
| `project_root_directory` | Your project root; used to build a snapshot's default name from its test.  |
| `web_url`                | The URL the interface is mounted at; shown after a run and on the UI.      |

You'll usually want the storage directory ignored by git:

```
# .gitignore
/tmp/snapshot_ui/
```

### 2. Mount the web interface

`SnapshotUI::Web` is a Rack application — mount it wherever your `web_url` points:

```ruby
# config.ru
require "snapshot_ui/web"
require_relative "config/snapshot_ui"

map "/ui/snapshots" do
  run SnapshotUI::Web
end
```

The interface only displays snapshots captured during testing, so mount it where you view them (typically a local
development server), not in production.

### 3. Take snapshots in your tests

Include the minitest helpers and call `take_snapshot` once a response is available:

```ruby
require "minitest/autorun"
require "rack/test"
require "snapshot_ui/test/minitest_helpers"

class ApplicationTest < Minitest::Spec
  include Rack::Test::Methods
  include SnapshotUI::Test::MinitestHelpers

  def app
    @app ||= Application.new
  end

  it "renders the root page" do
    get "/"

    take_snapshot(last_response)

    _(last_response.body).must_match("Hello")
  end
end
```

## Taking snapshots

```ruby
take_snapshot(snapshotee, title: nil, slug: nil)
```

* `snapshotee` — an object that responds to `#body` (such as `last_response`) or a plain `String` of HTML.
* `title` — the name shown in the list. Defaults to a name derived from the test.
* `slug` — a custom, stable URL for the snapshot (`/ui/snapshots/<slug>`); must be unique. Defaults to one derived
  from where the snapshot was taken.

You can take several snapshots in one test. `take_snapshot` does nothing unless snapshot-taking is enabled (see below),
so it's safe to leave in your tests.

## Running the tests and viewing snapshots

Snapshots are captured only when you enable them, via the minitest flag or an environment variable:

```sh
ruby -Itest test/application_test.rb --take-snapshots
# or
TAKE_SNAPSHOTS=1 rake test
```

At the end of the run the URL to review the snapshots is printed. Start your application and open that URL (e.g.
<http://localhost:3000/ui/snapshots>).

The page refreshes itself as snapshots change: it polls a lightweight version endpoint and updates when a new test run
publishes snapshots — no page reload, and no extra process or server to run. Everything the interface needs (styles
and scripts) is served by the app itself, so it works offline.

## How it works

* `take_snapshot` records the response body under `storage_directory` while your tests run.
* A minitest plugin (loaded when you require the helpers) publishes the run's snapshots at the end and prints the
  review URL.
* `SnapshotUI::Web` renders the list and each snapshot, and exposes a version endpoint the page polls for live updates.

## Requirements

* Ruby 3.3 or newer
* Rack 2.2, or Rack 3

## License

Released under the [MIT License](LICENSE.txt).
