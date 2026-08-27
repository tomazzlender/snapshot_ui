# frozen_string_literal: true

require "snapshot_ui"
require_relative "../mail_snapshot"

module SnapshotUI
  module Rails
    module Test
      # A single +take_snapshot+ for Rails tests that dispatches by what it is
      # given: an email (ActionMailer::MessageDelivery or Mail::Message) is
      # captured as a mail snapshot; anything else (a response, or a String of
      # HTML) is captured as a response snapshot.
      #
      # Included into both ActionDispatch::IntegrationTest and
      # ActionMailer::TestCase by the railtie, so one method covers both.
      module Helpers
        def take_snapshot(snapshotee, title: nil, slug: nil)
          return unless SnapshotUI.snapshot_taking_enabled?

          type, type_data = classify(snapshotee)
          SnapshotUI.exit_if_not_configured!
          increment_take_snapshot_counter_scoped_by_test

          context = {
            test_framework: "minitest",
            method_name: name,
            source_location: build_source_location(caller_locations(1..1).first),
            test_case_name: self.class.to_s,
            take_snapshot_index: _take_snapshot_counter - 1,
            metadata: {title: title, slug: slug}
          }

          if type == SnapshotUI::Rails::MailSnapshot::TYPE
            SnapshotUI::Rails::MailSnapshot.persist(snapshotee, context: context)
          else
            SnapshotUI::Snapshot.persist(snapshotee: snapshotee, context: context, type: type, type_data: type_data)
          end
        end

        private

        # Returns [type, type_data]. type_data is nil for responses (the core
        # extracts it from the snapshotee).
        def classify(snapshotee)
          if mail_like?(snapshotee)
            [SnapshotUI::Rails::MailSnapshot::TYPE, nil]
          elsif snapshotee.respond_to?(:body) || snapshotee.is_a?(String)
            [SnapshotUI::Snapshot::DEFAULT_TYPE, nil]
          else
            raise ArgumentError,
              "#take_snapshot accepts a response (something responding to #body), a String of HTML, " \
              "or an email (ActionMailer::MessageDelivery / Mail::Message). You provided `#{snapshotee.class}`."
          end
        end

        def mail_like?(object)
          (defined?(ActionMailer::MessageDelivery) && object.is_a?(ActionMailer::MessageDelivery)) ||
            (defined?(::Mail::Message) && object.is_a?(::Mail::Message))
        end

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
end
