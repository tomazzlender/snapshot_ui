# frozen_string_literal: true

require_relative "snapshot_ui/version"

module SnapshotUI
  class Error < StandardError; end

  class Configuration
    attr_accessor :storage_directory

    def initialize
      @storage_directory = "tmp/snapshots"
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
