# frozen_string_literal: true

# Publishes one snapshot into the dummy app's storage and prints the new
# version token. Used by the end-to-end browser check.
#
#   ruby gems/snapshot_ui-rails/test/dummy/bin/publish_snapshot.rb SLUG BODY

ENV["TAKE_SNAPSHOTS"] = "1"
ENV["RAILS_ENV"] = "test"

require_relative "../config/environment"
require "json"

slug, body = ARGV

SnapshotUI::Snapshot::Storage.write(slug, JSON.generate(
  type_data: {body: body},
  context: {
    test_framework: "minitest",
    test_case_name: "GreetingsTest",
    method_name: "test_show",
    source_location: [Rails.root.join("test/integration/greetings_test.rb").to_s, 5],
    take_snapshot_index: 0,
    metadata: {title: "Snapshot #{slug}", slug: slug}
  },
  slug: slug
))
SnapshotUI::Snapshot.publish_snapshots_in_progress

puts SnapshotUI::Snapshot::Storage.version
