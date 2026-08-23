# frozen_string_literal: true

require "snapshot_ui"
require_relative "rails/version"

module SnapshotUI
  # Rails integration for Snapshot UI. Requiring this file (which Bundler does
  # automatically for the +snapshot_ui-rails+ gem) loads the railtie that
  # configures Snapshot UI from the Rails application and adds the router and
  # test helpers.
  module Rails
    DEFAULT_MOUNT_PATH = "/ui/snapshots"

    class << self
      # The path the UI is mounted at. Set by the railtie from
      # +config.snapshot_ui.mount_path+; used to build default URLs and by
      # +mount_snapshot_ui+.
      attr_writer :mount_path

      def mount_path
        @mount_path || DEFAULT_MOUNT_PATH
      end

      # The URL printed after a test run and linked to from the empty state.
      # In a typical development setup the app is reachable at
      # http://localhost:3000; override with +config.snapshot_ui.web_url+ when
      # it isn't.
      def default_web_url(path = mount_path)
        "http://localhost:3000#{path}"
      end
    end
  end
end

require_relative "rails/railtie"
