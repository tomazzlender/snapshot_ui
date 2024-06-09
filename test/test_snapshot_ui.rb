# frozen_string_literal: true

require "test_helper"

class TestSnapshotUI < Minitest::Spec
  it "has a version number" do
    refute_nil ::SnapshotUI::VERSION
  end
end
