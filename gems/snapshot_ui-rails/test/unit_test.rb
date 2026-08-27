# frozen_string_literal: true

require_relative "test_helper"

class SnapshotUIRailsUnitTest < Minitest::Spec
  # A stand-in for a Rails application, enough for SnapshotUI::Rails.default_host.
  def app_double(default_url_options: nil, force_ssl: false)
    action_controller = Struct.new(:default_url_options).new(default_url_options)
    config = Struct.new(:action_controller, :force_ssl).new(action_controller, force_ssl)
    Struct.new(:config).new(config)
  end

  it "has a version number that matches the core gem" do
    _(SnapshotUI::Rails::VERSION).wont_be_nil
    _(SnapshotUI::Rails::VERSION).must_equal SnapshotUI::VERSION
  end

  it "exposes the configured mount path" do
    _(SnapshotUI::Rails.mount_path).must_equal "/rails/ui_snapshots"
  end

  it "builds a web url from a host and the mount path" do
    _(SnapshotUI::Rails.web_url(host: "http://localhost:3000")).must_equal "http://localhost:3000/rails/ui_snapshots"
    _(SnapshotUI::Rails.web_url(host: "http://localhost:4000/", mount_path: "/admin/snapshots"))
      .must_equal "http://localhost:4000/admin/snapshots"
  end

  it "defaults the host to localhost:3000 when the app declares nothing" do
    _(SnapshotUI::Rails.default_host(app_double)).must_equal "http://localhost:3000"
  end

  it "derives the host from the app's default_url_options" do
    _(SnapshotUI::Rails.default_host(app_double(default_url_options: {host: "example.test", port: 8080})))
      .must_equal "http://example.test:8080"
    _(SnapshotUI::Rails.default_host(app_double(default_url_options: {host: "myapp.local"})))
      .must_equal "http://myapp.local:3000"
  end

  it "uses https when the app forces SSL" do
    _(SnapshotUI::Rails.default_host(app_double(default_url_options: {host: "secure.test"}, force_ssl: true)))
      .must_equal "https://secure.test:3000"
  end

  it "picks up the PORT environment variable" do
    original = ENV["PORT"]
    ENV["PORT"] = "4567"
    _(SnapshotUI::Rails.default_host(app_double)).must_equal "http://localhost:4567"
  ensure
    ENV["PORT"] = original
  end

  it "registers the mount_snapshot_ui router helper" do
    _(ActionDispatch::Routing::Mapper.instance_methods).must_include :mount_snapshot_ui
  end

  it "names the mounted app so url helpers are generated" do
    _(Rails.application.routes.url_helpers).must_respond_to :snapshot_ui_path
  end
end
