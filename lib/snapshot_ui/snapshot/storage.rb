# frozen_string_literal: true

module SnapshotUI
  class Snapshot
    class Storage
      class << self
        def snapshots_directory
          SnapshotUI.configuration.storage_directory.join("snapshots")
        end

        def in_progress_directory
          SnapshotUI.configuration.storage_directory.join("in_progress")
        end

        def write(key, value)
          file_path = to_file_path_for_writing(key)
          file_path.dirname.mkpath
          file_path.write(value)
        end

        def read(key)
          to_file_path_for_reading(key).read
        end

        def list
          Dir
            .glob("#{snapshots_directory}/**/*.{json}")
            .map { |file_path| to_key(file_path) }
        end

        def clear(directory = nil)
          case directory
          when :snapshots
            snapshots_directory.rmtree
          when :in_progress
            in_progress_directory.rmtree
          else
            snapshots_directory.rmtree
            in_progress_directory.rmtree
          end
        end

        def publish_snapshots_in_progress
          clear(:snapshots)
          in_progress_directory.rename(snapshots_directory)
        end

        private

        def to_key(file_path)
          file_path.gsub(snapshots_directory.to_s + "/", "").gsub(".json", "")
        end

        def to_file_path_for_reading(key)
          snapshots_directory.join("#{key}.json")
        end

        def to_file_path_for_writing(key)
          in_progress_directory.join("#{key}.json")
        end
      end
    end
  end
end
