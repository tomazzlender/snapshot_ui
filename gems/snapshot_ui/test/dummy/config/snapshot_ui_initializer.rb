require "snapshot_ui"

SnapshotUI.configure do |config|
  config.storage_directory = File.expand_path("../tmp/snapshot_ui", __dir__)
  config.project_root_directory = File.expand_path("../", __dir__)
  config.web_url = "http://localhost:3001/ui/snapshots"
end
