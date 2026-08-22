# frozen_string_literal: true

require_relative "../test_helper"
require "rack/test"
require "rack/builder"
require "snapshot_ui/web"
require "json"
require_relative "../../test/helpers/fixture_helper"

class SnapshotUI::WebTest < Minitest::Spec
  include Rack::Test::Methods
  include FixtureHelper

  def app
    # Rack 2's Rack::Builder.parse_file returns [app, options], Rack 3's just the app.
    @app ||= Array(Rack::Builder.parse_file("test/dummy/config.ru")).first
  end

  it "renders an empty list of snapshots" do
    clean_snapshots

    get "/ui/snapshots"
    _(last_response.body).must_match("Snapshots")
    _(last_response.body).must_match("example integration test")
  end

  it "renders a list of snapshots" do
    copy_snapshot_fixture

    get "/ui/snapshots"
    _(last_response.body).must_match("Snapshots")
    _(last_response.body).must_match("renders a root page")
    _(last_response.body).must_match("snapshot with a custom path")
  end

  describe "with a generic slug" do
    it "renders a single snapshot" do
      copy_snapshot_fixture

      get "/ui/snapshots/test/dummy_test_19_0"
      _(last_response.body).must_match('<iframe id="raw" src="/ui/snapshots/raw/test/dummy_test_19_0">')
    end

    it "renders a raw response body of a snapshot" do
      copy_snapshot_fixture

      get "/ui/snapshots/raw/test/dummy_test_19_0"
      _(last_response.body).must_match("<html><body>Dummy App</body></html>")
    end
  end

  describe "with a user defined slug" do
    it "renders a single snapshot" do
      copy_snapshot_fixture

      get "/ui/snapshots/dummy-app"
      _(last_response.body).must_match('<iframe id="raw" src="/ui/snapshots/raw/dummy-app">')
    end

    it "renders a raw response body of a snapshot" do
      copy_snapshot_fixture

      get "/ui/snapshots/raw/dummy-app"
      _(last_response.body).must_match("<html><body>Dummy App</body></html>")
    end
  end

  it "when a snapshot for a given slug doesn't exist renders not found" do
    copy_snapshot_fixture

    get "/ui/snapshots/non-existing-slug"
    _(last_response.body).must_match("Not Found")
  end

  it "wires pages up for live updates, with all assets served by the app itself" do
    copy_snapshot_fixture

    get "/ui/snapshots"
    _(last_response.body).must_match('<body id="snapshots_index" data-controller="refresh" data-refresh-url-value="/ui/snapshots/version" data-refresh-version-value="')
    _(last_response.body).must_match(/data-refresh-version-value="\d+\.\d{9}"/)

    importmap = JSON.parse(last_response.body[%r{<script type="importmap"[^>]*>(.*?)</script>}m, 1])
    _(importmap["imports"].keys).must_include "@hotwired/turbo"
    _(importmap["imports"].keys).must_include "@hotwired/stimulus"
    asset_url = %r{\A/ui/snapshots/javascripts/[\w/]+\.js\?v=#{Regexp.escape(SnapshotUI::VERSION)}\z}o
    importmap["imports"].each_value do |url|
      _(url).must_match(asset_url)
    end
  end

  it "serves the bundled Turbo and Stimulus" do
    get "/ui/snapshots/javascripts/vendor/turbo.js"
    _(last_response.status).must_equal 200
    _(last_response.headers["content-type"]).must_match "javascript"
    _(last_response.body).must_match("Turbo")

    get "/ui/snapshots/javascripts/vendor/stimulus.js"
    _(last_response.status).must_equal 200
    _(last_response.body).must_match("Stimulus")
  end

  it "serves the version of the published snapshots for polling" do
    copy_snapshot_fixture

    get "/ui/snapshots/version"
    _(last_response.status).must_equal 200
    _(last_response.headers["content-type"]).must_equal "text/plain; charset=utf-8"
    _(last_response.headers["cache-control"]).must_equal "no-cache"
    _(last_response.body).must_match(/\A\d+\.\d{9}\z/)
    _(last_response.headers["etag"]).must_equal %("#{last_response.body}")
  end

  it "responds with 304 Not Modified while the client's version is current" do
    copy_snapshot_fixture

    get "/ui/snapshots/version"
    etag = last_response.headers["etag"]

    get "/ui/snapshots/version", {}, {"HTTP_IF_NONE_MATCH" => etag}
    _(last_response.status).must_equal 304
    _(last_response.body).must_be_empty

    get "/ui/snapshots/version", {}, {"HTTP_IF_NONE_MATCH" => '"stale"'}
    _(last_response.status).must_equal 200
  end

  it "serves version 0 when there are no published snapshots" do
    clean_snapshots

    get "/ui/snapshots/version"
    _(last_response.status).must_equal 200
    _(last_response.body).must_equal "0"
  end
end
