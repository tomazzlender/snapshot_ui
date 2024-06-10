# frozen_string_literal: true

require_relative "../test_helper"
require "rack/test"
require "rack/builder"
require "snapshot_ui/web"

class SnapshotUI::WebTest < Minitest::Spec
  include Rack::Test::Methods

  def app
    @app ||= Rack::Builder.parse_file("test/dummy/config.ru")
  end

  it "renders a list of snapshots" do
    get "/ui/snapshots"
    _(last_response.body).must_match("Snapshots")
    _(last_response.body).must_match("Instructions...")
  end

  it "renders a single snapshot" do
    get "/ui/snapshots/response/test_0001_renders%20a%20root%20page"
    _(last_response.body).must_match('<iframe id="raw" src="/ui/snapshots/response/raw/test_0001_renders%20a%20root%20page">')
  end

  it "renders a raw response body of a snapshot" do
    get "/ui/snapshots/response/raw/test_0001_renders%20a%20root%20page"
    _(last_response.body).must_match("<html><body>Dummy App</body></html>")
  end

  it "when a snapshot for a given slug doesn't exist renders not found" do
    get "/ui/snapshots/non-existing-slug"
    _(last_response.body).must_match("Not Found")
  end
end
