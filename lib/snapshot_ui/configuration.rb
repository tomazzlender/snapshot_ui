# frozen_string_literal: true

module SnapshotUI
  class Configuration
    attr_writer :storage_directory, :project_root_directory

    def initialize(project_root_directory:, storage_directory:)
      @project_root_directory = project_root_directory
      @storage_directory = storage_directory
    end

    def storage_directory
      Pathname.new(@storage_directory)
    end

    def project_root_directory
      Pathname.new(@project_root_directory)
    end
  end
end
