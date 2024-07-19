# frozen_string_literal: true

require "rack/test"
require "rack/builder"
require_relative "../../test_helper"
require_relative "../../../lib/snapshot_ui/test/minitest_helpers"

describe "dummy app" do
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

  describe "first nested test group" do
    it "renders a root page inside the first nested describe" do
      get "/"
      take_snapshot(last_response)

      _(last_response.body).must_match("Dummy App")
    end

    describe "second nested test group" do
      it "renders a root page inside the second nested describe" do
        get "/"
        take_snapshot(last_response)

        _(last_response.body).must_match("Dummy App")
      end

      it "renders again a root page inside the second nested describe" do
        get "/"
        take_snapshot(last_response)

        _(last_response.body).must_match("Dummy App")
      end

      describe "third nested test group" do
        it "renders a root page inside the third nested describe" do
          get "/"
          take_snapshot(last_response)

          _(last_response.body).must_match("Dummy App")
        end

        describe "forth nested test group" do
          it "renders a root page inside the forth nested describe" do
            get "/"
            take_snapshot(last_response)

            _(last_response.body).must_match("Dummy App")
          end
        end
      end
    end
  end
end
