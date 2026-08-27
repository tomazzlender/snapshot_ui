# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../helpers/fixture_helper"

class SnapshotUI::SnapshotTest < Minitest::Spec
  include FixtureHelper

  after { clean_snapshots }

  it "raises NotFound for a missing or unreadable snapshot" do
    _ { SnapshotUI::Snapshot.find("missing") }.must_raise SnapshotUI::Snapshot::NotFound

    SnapshotUI::Snapshot::Storage.snapshots_directory.mkpath
    SnapshotUI::Snapshot::Storage.snapshots_directory.join("broken.json").write("{ not json")
    _ { SnapshotUI::Snapshot.find("broken") }.must_raise SnapshotUI::Snapshot::NotFound
  end
end
