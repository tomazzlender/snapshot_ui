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
    _(last_response.body).must_match("A list of snapshots")
  end
end
