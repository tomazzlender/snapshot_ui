# frozen_string_literal: true

require "rails/railtie"
require "snapshot_ui"

module SnapshotUI
  module Rails
    # Wires Snapshot UI into a Rails application:
    #
    # * fills in the configuration Snapshot UI needs from what Rails already
    #   knows (its root, its tmp directory and the mount path), so no
    #   initializer is required;
    # * adds +mount_snapshot_ui+ to the router;
    # * makes +take_snapshot+ available in integration tests.
    #
    # Anything can still be overridden in an initializer, which runs after this
    # railtie's own initializers.
    class Railtie < ::Rails::Railtie
      # Configuration lives under +config.snapshot_ui+.
      #
      #   # config/application.rb or an initializer
      #   config.snapshot_ui.mount_path = "/admin/ui/snapshots"
      #   config.snapshot_ui.web_url    = "http://localhost:4000/admin/ui/snapshots"
      config.snapshot_ui = ActiveSupport::OrderedOptions.new
      config.snapshot_ui.mount_path = "/ui/snapshots"
      config.snapshot_ui.web_url = nil

      initializer "snapshot_ui.configure" do |app|
        options = app.config.snapshot_ui
        SnapshotUI::Rails.mount_path = options.mount_path

        SnapshotUI.configure do |config|
          config.project_root_directory ||= ::Rails.root.to_s
          config.storage_directory ||= ::Rails.root.join("tmp", "snapshot_ui").to_s
          config.web_url = options.web_url || SnapshotUI::Rails.default_web_url(options.mount_path)
        end
      end

      # +take_snapshot+ in integration tests, without an explicit include.
      # The `mount_snapshot_ui` router helper.
      initializer "snapshot_ui.routes" do
        require_relative "routes"
      end

      initializer "snapshot_ui.test_helpers" do
        ActiveSupport.on_load(:action_dispatch_integration_test) do
          require "snapshot_ui/test/minitest_helpers"
          include SnapshotUI::Test::MinitestHelpers
        end
      end
    end
  end
end
