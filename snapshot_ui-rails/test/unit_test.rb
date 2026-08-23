# frozen_string_literal: true

require_relative "test_helper"

class SnapshotUIRailsUnitTest < Minitest::Spec
  it "has a version number that matches the core gem" do
    _(SnapshotUI::Rails::VERSION).wont_be_nil
    _(SnapshotUI::Rails::VERSION).must_equal SnapshotUI::VERSION
  end

  it "exposes the configured mount path" do
    _(SnapshotUI::Rails.mount_path).must_equal "/rails/ui_snapshots"
  end

  it "builds a default web url from a mount path" do
    _(SnapshotUI::Rails.default_web_url("/admin/ui/snapshots")).must_equal "http://localhost:3000/admin/ui/snapshots"
  end

  it "registers the mount_snapshot_ui router helper" do
    _(ActionDispatch::Routing::Mapper.instance_methods).must_include :mount_snapshot_ui
  end

  it "names the mounted app so url helpers are generated" do
    _(Rails.application.routes.url_helpers).must_respond_to :snapshot_ui_path
  end
end
