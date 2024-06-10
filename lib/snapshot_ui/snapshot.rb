# frozen_string_literal: true

module SnapshotUI
  class Snapshot
    def self.all
      storage_directory = SnapshotUI.configuration.storage_directory

      Dir.glob("#{storage_directory}/*.html").map do |file|
        File.basename(file, ".html")
      end
    end
  end
end
