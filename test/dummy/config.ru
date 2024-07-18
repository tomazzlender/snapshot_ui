# frozen_string_literal: true

# A dummy Rack application that demonstrates how to use SnapshotUI.
#
# Run with `bundle exec puma test/dummy/config.ru -p 3001`
# Then open http://localhost:3001/ui/snapshots

require "snapshot_ui/web"
require_relative "config/snapshot_ui_initializer"

dummy_app =
  Rack::Builder.app do
    map "/" do
      run lambda { |_env| [200, {"content-type" => "text/html"}, ["<html><body>Dummy App</body></html>"]] }
    end

    map "/ui/snapshots" do
      run SnapshotUI::Web
    end
  end

run dummy_app
