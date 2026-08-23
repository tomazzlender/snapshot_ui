# frozen_string_literal: true

# Seeds the demo snapshots used by the screenshot report. Run with
# RAILS_ENV=test TAKE_SNAPSHOTS=1.

ENV["TAKE_SNAPSHOTS"] = "1"
ENV["RAILS_ENV"] = "test"

require_relative "../config/environment"
require "snapshot_ui/rails/mail_snapshot"
require "snapshot_ui/snapshot"

SnapshotUI.clear_snapshots

def context(test_case:, method:, line:, slug:, title: nil)
  {
    test_framework: "minitest",
    test_case_name: test_case,
    method_name: method,
    source_location: [Rails.root.join("test/mailers/notifier_mailer_test.rb").to_s, line],
    take_snapshot_index: 0,
    metadata: {title: title, slug: slug}
  }
end

# --- mail snapshots ---
SnapshotUI::Rails::MailSnapshot.persist(
  NotifierMailer.welcome("Ada"),
  context: context(test_case: "NotifierMailerTest", method: "test_welcome", line: 6, slug: "welcome", title: "Welcome email")
)
SnapshotUI::Rails::MailSnapshot.persist(
  NotifierMailer.receipt,
  context: context(test_case: "NotifierMailerTest", method: "test_receipt", line: 14, slug: "receipt", title: "Order receipt")
)
SnapshotUI::Rails::MailSnapshot.persist(
  NotifierMailer.html_only,
  context: context(test_case: "NotifierMailerTest", method: "test_html_only", line: 22, slug: "html-only")
)
SnapshotUI::Rails::MailSnapshot.persist(
  NotifierMailer.text_only,
  context: context(test_case: "NotifierMailerTest", method: "test_text_only", line: 30, slug: "text-only")
)

# --- a response snapshot, so the index shows the two types side by side ---
SnapshotUI::Snapshot.persist(
  snapshotee: "<!doctype html><html><body style='font-family: system-ui; padding:40px'><h1>Thank you!</h1><p>Your membership is confirmed.</p></body></html>",
  context: context(test_case: "MembershipsTest", method: "test_thank_you_page", line: 12, slug: "thank-you", title: "Thank you page"),
  type: "response"
)

SnapshotUI::Snapshot.publish_snapshots_in_progress
puts "Seeded #{SnapshotUI::Snapshot::Storage.list.size} snapshots: #{SnapshotUI::Snapshot::Storage.list.sort.join(", ")}"
