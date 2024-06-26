# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "snapshot_ui"
require "minitest/autorun"

SnapshotUI.configure do |config|
  config.storage_directory = File.expand_path("./dummy/tmp/snapshot_ui", __dir__)
  config.project_root_directory = File.expand_path("./dummy", __dir__)
  config.web_url = "http://localhost:3001/ui/snapshots"
end
