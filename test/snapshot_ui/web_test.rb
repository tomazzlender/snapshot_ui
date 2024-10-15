# frozen_string_literal: true

require_relative "../test_helper"
require "rack/test"
require "rack/builder"
require "snapshot_ui/web"
require_relative "../../test/helpers/fixture_helper"

class SnapshotUI::WebTest < Minitest::Spec
  include Rack::Test::Methods
  include FixtureHelper

  def app
    @app ||= Rack::Builder.parse_file("test/dummy/config.ru")
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
end
