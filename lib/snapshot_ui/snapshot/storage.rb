# frozen_string_literal: true

module SnapshotUI
  class Snapshot
    class Storage
      class InvalidKey < StandardError; end

      class << self
        def snapshots_directory
          SnapshotUI.configuration.storage_directory.join("snapshots")
        end

        def in_progress_directory
          SnapshotUI.configuration.storage_directory.join("in_progress")
        end

        # Holds the previously published snapshots for the brief moment while the
        # ones in progress take their place.
        def previous_snapshots_directory
          SnapshotUI.configuration.storage_directory.join("previous_snapshots")
        end

        # A token that changes whenever the published snapshots change.
        #
        # Publishing swaps in a freshly created directory (see
        # .publish_snapshots_in_progress), so its inode identifies the published
        # set even when the filesystem gives consecutive directories the same
        # modification time.
        def version
          return "0" unless snapshots_directory.exist?

          stat = snapshots_directory.stat
          format("%d.%09d-%d", stat.mtime.to_i, stat.mtime.nsec, stat.ino)
        end

        def write(key, value)
          file_path = to_file_path_for_writing(key)
          file_path.dirname.mkpath
          file_path.write(value)
        end

        def read(key)
          to_file_path_for_reading(key).read
        end

        # True when +key+ maps to a file inside the snapshots directory. A slug
        # coming from the URL is untrusted, so paths escaping the directory
        # (via "..", say) must be refused.
        def readable?(key)
          to_file_path_for_reading(key)
          true
        rescue InvalidKey
          false
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
            previous_snapshots_directory.rmtree if previous_snapshots_directory.exist?
          end
        end

        # Replaces the published snapshots with the ones in progress. The published
        # directory is moved aside rather than deleted first, so that there is
        # practically no moment without published snapshots (the web UI polls for
        # changes and would otherwise briefly show an empty list).
        def publish_snapshots_in_progress
          previous_snapshots_directory.rmtree if previous_snapshots_directory.exist?
          snapshots_directory.rename(previous_snapshots_directory) if snapshots_directory.exist?
          in_progress_directory.rename(snapshots_directory)
          previous_snapshots_directory.rmtree if previous_snapshots_directory.exist?
        end

        private

        def to_key(file_path)
          file_path.gsub(snapshots_directory.to_s + "/", "").gsub(".json", "")
        end

        def to_file_path_for_reading(key)
          within(snapshots_directory, key)
        end

        def to_file_path_for_writing(key)
          within(in_progress_directory, key)
        end

        # Resolves +key+ to a "#{key}.json" file and ensures it stays inside
        # +directory+, raising InvalidKey otherwise.
        def within(directory, key)
          directory = directory.expand_path
          file_path = directory.join("#{key}.json").expand_path

          unless file_path == directory || file_path.to_s.start_with?(directory.to_s + File::SEPARATOR)
            raise InvalidKey, "#{key.inspect} is not a valid snapshot slug."
          end

          file_path
        end
      end
    end
  end
end
