module SnapshotUI
  module Test
    module RackTestHelpers
      def take_snapshot(snapshotee)
        Pathname.new(SnapshotUI.configuration.storage_directory).mkpath
        file_path = File.join(SnapshotUI.configuration.storage_directory, "sample_test_case.html")
        File.write(file_path, snapshotee.body)
      end
    end
  end
end
