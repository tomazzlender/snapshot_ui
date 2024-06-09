module SnapshotUI
  module Test
    module RackTestHelpers
      def take_snapshot(snapshotee)
        puts "\n== Snapshot Details ==\n"
        puts snapshotee.body
        puts "======================"
      end
    end
  end
end
