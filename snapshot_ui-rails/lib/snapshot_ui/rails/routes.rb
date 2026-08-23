# frozen_string_literal: true

require "snapshot_ui/web"

module ActionDispatch
  module Routing
    class Mapper
      # Mounts the Snapshot UI web interface.
      #
      #   # config/routes.rb
      #   mount_snapshot_ui
      #   mount_snapshot_ui at: "/admin/ui/snapshots"
      #
      # With no argument it mounts at +config.snapshot_ui.mount_path+
      # (default +/ui/snapshots+).
      def mount_snapshot_ui(at: SnapshotUI::Rails.mount_path)
        mount SnapshotUI::Web, at: at, as: "snapshot_ui"
      end
    end
  end
end
