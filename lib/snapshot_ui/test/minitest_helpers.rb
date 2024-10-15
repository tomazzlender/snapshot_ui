# frozen_string_literal: true

require_relative "../../snapshot_ui"
require_relative "../snapshot"

module SnapshotUI
  module Test
    module MinitestHelpers
      # Takes a snapshot of a given +snapshotee+, with an optional +title+ metadata.
      #
      # A +snapshotee+ can be an object that responds to +#body+ or of class +String+.
      #
      # +take_snapshot+ needs to be called after the +snapshotee+ object becomes available
      # for inspection in the lifecycle of the test. You can take one or more snapshots in a single test case.
      #
      # @param snapshotee [Object, String] an +Object+ that responds to the +#body+ method that returns a +String+, or a +String+
      # @param title [String, nil] (optional) a title of the snapshotee. When not provided the title will be generated from a test description.
      # @param slug [String, nil] (optional) a custom URL path for the snapshot (e.g. +/ui/snapshots/__SLUG__+). +slug+ must be unique across all snapshots.
      #   If not provided, the slug will be automatically generated based on where the snapshot was taken.
      # @return SnapshotUI::Snapshot
      def take_snapshot(snapshotee, title: nil, slug: nil)
        return unless SnapshotUI.snapshot_taking_enabled?

        unless snapshotee.respond_to?(:body) || snapshotee.is_a?(String)
          message =
            "#take_snapshot only accepts an argument that responds to a method `#body` " \
            "or an argument that is of type `String`. " \
            "You provided an argument of type `#{snapshotee.class}` that does not respond to `#body` nor is a `String`."
          raise ArgumentError, message
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
            take_snapshot_index: _take_snapshot_counter - 1,
            metadata: {title: title, slug: slug}
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
