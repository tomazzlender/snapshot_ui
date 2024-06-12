# frozen_string_literal: true

# A dummy Rack application that demonstrates how to use SnapshotUI.
#
# Run with `bundle exec puma test/dummy/config.ru -p 3001`
# Then open http://localhost:3001/ui/snapshots

require "snapshot_ui"
require "snapshot_ui/web"

SnapshotUI.configure do |config|
  config.storage_directory = "#{File.expand_path(__dir__)}/tmp/snapshot_ui"
  config.project_root_directory = File.expand_path(__dir__)
end

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
