module SnapshotUI
  module Test
    module RackTestHelpers
      def take_snapshot(snapshotee)
        test_case_name = @NAME
        Pathname.new(SnapshotUI.configuration.storage_directory).mkpath
        file_path = File.join(SnapshotUI.configuration.storage_directory, "#{test_case_name}.html")
        File.write(file_path, snapshotee.body)
      end
    end
  end
end
