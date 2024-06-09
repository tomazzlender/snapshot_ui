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

  it "renders a single sample snapshot" do
    get "/ui/snapshots/sample-test-case-one"
    _(last_response.body).must_match("A raw render of a snapshot response...")
  end

  it "when a snapshot for a given slug doesn't exist renders not found" do
    get "/ui/snapshots/non-existing-slug"
    _(last_response.body).must_match("Not Found")
  end
end
