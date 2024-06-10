# frozen_string_literal: true

module SnapshotUI
  class Snapshot
    def self.all
      storage_directory = SnapshotUI.configuration.storage_directory

      Dir.glob("#{storage_directory}/*.html").map do |file|
        File.basename(file, ".html")
      end
    end

    def self.read_response_body(slug)
      storage_directory = SnapshotUI.configuration.storage_directory

      File.read([storage_directory, "/", URI.decode_www_form_component(slug), ".html"].join)
    end
  end
end
