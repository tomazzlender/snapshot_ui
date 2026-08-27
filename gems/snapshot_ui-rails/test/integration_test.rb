# frozen_string_literal: true

require_relative "test_helper"

# Exercises the whole Rails integration through a booted dummy application:
# configuration filled in from Rails, the UI mounted via `mount_snapshot_ui`,
# and `take_snapshot` available in an integration test without an include.
class SnapshotUIRailsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    SnapshotUI.clear_snapshots
    SnapshotUI::Snapshot::Storage.in_progress_directory.rmtree if SnapshotUI::Snapshot::Storage.in_progress_directory.exist?
  end

  teardown do
    SnapshotUI.clear_snapshots
  end

  test "take_snapshot is available without including anything" do
    assert_respond_to self, :take_snapshot
  end

  test "Snapshot UI is configured from the Rails application" do
    assert_equal Rails.root.to_s, SnapshotUI.configuration.project_root_directory.to_s
    assert_equal Rails.root.join("tmp", "snapshot_ui").to_s, SnapshotUI.configuration.storage_directory.to_s
    assert_equal "http://localhost:3000/rails/ui_snapshots", SnapshotUI.configuration.web_url
  end

  test "taking a snapshot of a Rails response writes it under the app's tmp directory" do
    get "/hello"
    assert_response :success

    take_snapshot(response, slug: "hello")
    SnapshotUI::Snapshot.publish_snapshots_in_progress

    snapshot = SnapshotUI::Snapshot.find("hello")
    assert_includes snapshot.body, "Hello from Rails"
    assert_path_exists Rails.root.join("tmp", "snapshot_ui", "snapshots", "hello.json")
  end

  test "the mounted UI lists the snapshots" do
    get "/hello"
    take_snapshot(response, title: "The greeting", slug: "hello")
    SnapshotUI::Snapshot.publish_snapshots_in_progress

    get "/rails/ui_snapshots"
    assert_response :success
    assert_includes response.body, "Snapshots"
    assert_includes response.body, "The greeting"
  end

  test "the mounted UI serves a snapshot's raw body" do
    get "/hello"
    take_snapshot(response, slug: "hello")
    SnapshotUI::Snapshot.publish_snapshots_in_progress

    get "/rails/ui_snapshots/raw/hello"
    assert_response :success
    assert_includes response.body, "Hello from Rails"
  end

  test "the mounted UI serves its version endpoint for polling" do
    get "/rails/ui_snapshots/version"
    assert_response :success
    assert_equal "0", response.body, "no snapshots published yet"

    get "/hello"
    take_snapshot(response, slug: "hello")
    SnapshotUI::Snapshot.publish_snapshots_in_progress

    get "/rails/ui_snapshots/version"
    assert_response :success
    assert_match(/\A\d+\.\d{9}-\d+\z/, response.body)
  end

  test "an unknown snapshot renders the not-found page with a 404" do
    get "/rails/ui_snapshots/does-not-exist"
    assert_response :not_found
    assert_includes response.body, "Not Found"
  end
end
