# Run with `bundle exec puma test/dummy/config.ru -p 3001`
# Then open http://localhost:3001/ui/snapshots

require "snapshot_ui"
require "snapshot_ui/web"

SnapshotUI.configure do |config|
  config.storage_directory = "#{File.expand_path("..", __FILE__)}/tmp/snapshots"
end

dummy_app =
  Rack::Builder.app do
    map "/" do
      run lambda { |_env| [200, {"content-type" => "text/html"}, ["<html><body>Dummy App</body></html>"]] }
    end

    map "/ui/snapshots" do
      run SnapshotUI::Web.new
    end
  end

run dummy_app
