# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../helpers/fixture_helper"

class SnapshotUI::Snapshot::StorageTest < Minitest::Spec
  include FixtureHelper

  let(:storage) { SnapshotUI::Snapshot::Storage }

  it "reports version 0 when there are no published snapshots" do
    clean_snapshots

    _(storage.version).must_equal "0"
  end

  it "keeps the version unchanged while snapshots are only in progress" do
    copy_snapshot_fixture
    version_before = storage.version

    storage.write("test/new_test_1_0", "{}")

    _(storage.version).must_equal version_before
  end

  it "changes the version when snapshots in progress are published" do
    copy_snapshot_fixture
    version_before = storage.version

    storage.write("test/new_test_1_0", "{}")
    storage.publish_snapshots_in_progress

    _(storage.version).must_match(/\A\d+\.\d{9}\z/)
    _(storage.version).wont_equal version_before
  end

  it "replaces the published snapshots with the ones in progress" do
    copy_snapshot_fixture
    storage.write("test/new_test_1_0", "{}")

    storage.publish_snapshots_in_progress

    _(storage.list).must_equal ["test/new_test_1_0"]
    _(storage.in_progress_directory.exist?).must_equal false
    _(storage.previous_snapshots_directory.exist?).must_equal false
  end

  it "publishes snapshots in progress when nothing was published before" do
    clean_snapshots
    storage.write("test/new_test_1_0", "{}")

    storage.publish_snapshots_in_progress

    _(storage.list).must_equal ["test/new_test_1_0"]
  end
end
