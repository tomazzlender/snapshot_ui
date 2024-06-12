# frozen_string_literal: true

require "minitest/autorun"
require "rack/test"
require "rack/builder"
require_relative "../../../lib/snapshot_ui/test/minitest_helpers"

class DummyTest < Minitest::Spec
  include Rack::Test::Methods
  include SnapshotUI::Test::MinitestHelpers

  def app
    @app ||= Rack::Builder.parse_file("test/dummy/config.ru")
  end

  it "renders a root page" do
    get "/"

    take_snapshot(last_response)

    _(last_response.body).must_match("Dummy App")
  end
end
