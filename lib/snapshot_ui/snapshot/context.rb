# frozen_string_literal: true

module SnapshotUI
  class Snapshot
    class Context
      attr_reader :test_framework, :test_case_name, :method_name, :source_location, :take_snapshot_index, :metadata

      def initialize(context)
        @test_framework = context[:test_framework]
        @test_case_name = context[:test_case_name]
        @method_name = context[:method_name]
        @source_location = context[:source_location]
        @take_snapshot_index = context[:take_snapshot_index]
        @metadata = context[:metadata]
      end

      def to_slug
        test_path_without_extension =
          source_location[0]
            .delete_suffix(File.extname(source_location[0]))
            .delete_prefix(SnapshotUI.configuration.project_root_directory.to_s + "/")

        [test_path_without_extension, source_location[1], take_snapshot_index].join("_")
      end

      def name
        method_name
      end

      def test_group
        test_case_name
      end

      def order_index
        source_location.dup << take_snapshot_index
      end
    end
  end
end
