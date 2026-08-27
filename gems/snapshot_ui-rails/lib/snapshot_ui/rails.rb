# frozen_string_literal: true

require "snapshot_ui"
require_relative "rails/version"

module SnapshotUI
  # Rails integration for Snapshot UI. Requiring this file (which Bundler does
  # automatically for the +snapshot_ui-rails+ gem) loads the railtie that
  # configures Snapshot UI from the Rails application and adds the router and
  # test helpers.
  #
  # With the defaults no configuration is needed. To override, set values under
  # +config.snapshot_ui+ (see the README).
  module Rails
    DEFAULT_MOUNT_PATH = "/rails/ui_snapshots"
    DEFAULT_HOST = "http://localhost:3000"

    class << self
      # The path the UI is mounted at. Set by the railtie from
      # +config.snapshot_ui.mount_path+; used to build the default web URL and
      # by +mount_snapshot_ui+.
      attr_writer :mount_path

      def mount_path
        @mount_path || DEFAULT_MOUNT_PATH
      end

      # Builds the URL the "ready for review" message and the empty-state link
      # point at, from a host (scheme://host:port) and the mount path.
      def web_url(host:, mount_path: self.mount_path)
        "#{host.to_s.chomp("/")}#{mount_path}"
      end

      # The host (scheme://host[:port]) to use when the application hasn't been
      # told one explicitly. Rails does not know the address its development
      # server will bind to, so this is a best effort: the host declared in
      # +config.action_controller.default_url_options+ if present, then the PORT
      # environment variable, then the conventional http://localhost:3000.
      def default_host(app)
        options = default_url_options(app)
        return DEFAULT_HOST if options.empty? && !ENV.key?("PORT")

        scheme = url_scheme(app, options)
        host = options[:host] || "localhost"
        port = options[:port] || ENV["PORT"] || 3000

        "#{scheme}://#{host}:#{port}"
      end

      private

      def default_url_options(app)
        app.config.action_controller.default_url_options || {}
      rescue
        {}
      end

      def url_scheme(app, options)
        scheme = options[:protocol] || (app.config.force_ssl ? "https" : "http")
        scheme.to_s.sub(%r{://\z}, "")
      end
    end
  end
end

require_relative "rails/railtie"
