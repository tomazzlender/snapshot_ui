# frozen_string_literal: true

require_relative "../../snapshot_ui"
require_relative "../snapshot"

module SnapshotUI
  module Test
    module MinitestHelpers
      def take_snapshot(snapshotee)
        return unless SnapshotUI.snapshot_taking_enabled?

        unless snapshotee.respond_to?(:body)
          message =
            "#take_snapshot only accepts an argument that responds to a method `#body`. " \
            "You provided an argument of type `#{snapshotee.class}` that does not respond to `#body`."
          raise ArgumentError.new(message)
        end

        SnapshotUI.exit_if_not_configured!

        increment_take_snapshot_counter_scoped_by_test

        SnapshotUI::Snapshot.persist(
          snapshotee: snapshotee,
          context: {
            test_framework: "minitest",
            method_name: name,
            source_location: build_source_location(caller_locations(1..1).first),
            test_case_name: self.class.to_s,
            take_snapshot_index: _take_snapshot_counter - 1
          }
        )
      end

      private

      attr_reader :_take_snapshot_counter

      def increment_take_snapshot_counter_scoped_by_test
        @_take_snapshot_counter ||= 0
        @_take_snapshot_counter += 1
      end

      def build_source_location(caller_location)
        [caller_location.path, caller_location.lineno]
      end
    end
  end
end
