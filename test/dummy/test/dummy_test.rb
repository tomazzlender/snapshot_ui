# frozen_string_literal: true

require "rack/test"
require "rack/builder"
require_relative "../../test_helper"
require_relative "../../../lib/snapshot_ui/test/minitest_helpers"

class DummyTest < Minitest::Test
  include Rack::Test::Methods
  include SnapshotUI::Test::MinitestHelpers

  def app
    @app ||= Rack::Builder.parse_file("test/dummy/config.ru")
  end

  class FirstNestedGroup < DummyTest
    def test_2nd_renders_a_root_page_inside_a_first_nested_describe
      get "/"
      take_snapshot(last_response)

      assert_match "Dummy App", last_response.body
    end
  end

  class SecondNestedGroup < DummyTest
    def test_3rd_renders_a_root_page_inside_a_second_nested_describe
      get "/"
      take_snapshot(last_response)

      assert_match "Dummy App", last_response.body
    end

    def test_4th_renders_again_a_root_page_inside_a_second_nested_describe
      get "/"
      take_snapshot(last_response)

      assert_match "Dummy App", last_response.body
    end
  end

  class ThirdNestedGroup < DummyTest
    def test_5th_renders_a_root_page_inside_a_third_nested_describe
      get "/"
      take_snapshot(last_response)

      assert_match "Dummy App", last_response.body
    end
  end
end
