# frozen_string_literal: true

require "rails/railtie"
require "snapshot_ui"

module SnapshotUI
  module Rails
    # Wires Snapshot UI into a Rails application:
    #
    # * fills in the configuration Snapshot UI needs from what Rails already
    #   knows (its root, its tmp directory and the mount path), so with the
    #   defaults no initializer is required;
    # * adds +mount_snapshot_ui+ to the router;
    # * makes +take_snapshot+ available in integration tests.
    #
    # To override anything, set it under +config.snapshot_ui+ in
    # +config/initializers/snapshot_ui.rb+ (or an environment file):
    #
    #   Rails.application.configure do
    #     config.snapshot_ui.mount_path = "/admin/snapshots"
    #     config.snapshot_ui.host       = "http://localhost:4000"
    #   end
    class Railtie < ::Rails::Railtie
      config.snapshot_ui = ActiveSupport::OrderedOptions.new
      # The path the UI is mounted at.
      config.snapshot_ui.mount_path = nil
      # The scheme://host[:port] the UI is reachable at, for the "ready for
      # review" message. Defaults to the application's declared host, else
      # http://localhost:3000. See SnapshotUI::Rails.default_host.
      config.snapshot_ui.host = nil
      # A full URL that overrides both of the above for the printed message.
      # Rarely needed; prefer mount_path + host.
      config.snapshot_ui.web_url = nil

      # The mount path is known immediately, so the router helper and the
      # storage paths can use it.
      initializer "snapshot_ui.configure" do |app|
        SnapshotUI::Rails.mount_path = app.config.snapshot_ui.mount_path if app.config.snapshot_ui.mount_path

        SnapshotUI.configure do |config|
          config.project_root_directory ||= ::Rails.root.to_s
          config.storage_directory ||= ::Rails.root.join("tmp", "snapshot_ui").to_s
        end
      end

      # The web URL is resolved after initialization so that a host declared in
      # a user initializer (config.action_controller.default_url_options, or
      # config.snapshot_ui.host) has already been set.
      config.after_initialize do |app|
        options = app.config.snapshot_ui

        SnapshotUI.configuration.web_url =
          options.web_url ||
          SnapshotUI::Rails.web_url(host: options.host || SnapshotUI::Rails.default_host(app))
      end

      # The +mount_snapshot_ui+ router helper.
      initializer "snapshot_ui.routes" do
        require_relative "routes"
      end

      # Teach the web interface to render "mail" snapshots.
      initializer "snapshot_ui.mail_renderer" do
        require "snapshot_ui/web"
        require_relative "mail_snapshot"
        require_relative "web/mail_renderer"
        SnapshotUI::Web.register_renderer(
          SnapshotUI::Rails::MailSnapshot::TYPE,
          SnapshotUI::Rails::Web::MailRenderer
        )
      end

      # +take_snapshot+ in tests, without an explicit include. One helper covers
      # both integration tests (responses) and mailer tests (emails).
      initializer "snapshot_ui.test_helpers" do
        ActiveSupport.on_load(:action_dispatch_integration_test) do
          require_relative "test/helpers"
          include SnapshotUI::Rails::Test::Helpers
        end

        ActiveSupport.on_load(:action_mailer_test_case) do
          require_relative "test/helpers"
          include SnapshotUI::Rails::Test::Helpers
        end
      end
    end
  end
end
