# frozen_string_literal: true

require_relative "test_helper"

# take_snapshot(mail) in a mailer test, with no explicit include, capturing both
# the HTML and text alternatives from one call.
class NotifierMailerSnapshotTest < ActionMailer::TestCase
  setup { SnapshotUI.clear_snapshots }
  teardown { SnapshotUI.clear_snapshots }

  test "take_snapshot is available in a mailer test without including anything" do
    assert_respond_to self, :take_snapshot
  end

  test "captures a multipart email as a mail snapshot" do
    take_snapshot(NotifierMailer.welcome("Ada"), slug: "welcome")
    SnapshotUI::Snapshot.publish_snapshots_in_progress

    snapshot = SnapshotUI::Snapshot.find("welcome")
    assert_equal "mail", snapshot.type

    mail = SnapshotUI::Rails::Mail.new(snapshot)
    assert mail.multipart_alternatives?, "both HTML and text parts should be present"
    assert_includes mail.part_body("text/html"), "Welcome, Ada"
    assert_includes mail.part_body("text/plain"), "Welcome, Ada"
    assert_equal "NotifierMailer", mail.mailer
    assert_equal "welcome", mail.action
    assert_equal ["welcome.txt"], mail.attachments.map(&:filename)
  end

  test "captures an html-only email" do
    take_snapshot(NotifierMailer.html_only, slug: "html-only")
    SnapshotUI::Snapshot.publish_snapshots_in_progress

    mail = SnapshotUI::Rails::Mail.new(SnapshotUI::Snapshot.find("html-only"))
    assert mail.html?
    refute mail.text?
    refute mail.multipart_alternatives?
    assert_includes mail.part_body("text/html"), "HTML part only"
  end

  test "captures a text-only email" do
    take_snapshot(NotifierMailer.text_only, slug: "text-only")
    SnapshotUI::Snapshot.publish_snapshots_in_progress

    mail = SnapshotUI::Rails::Mail.new(SnapshotUI::Snapshot.find("text-only"))
    assert mail.text?
    refute mail.html?
    assert_includes mail.part_body("text/plain"), "plain-text part only"
  end

  test "accepts a bare Mail::Message" do
    take_snapshot(NotifierMailer.welcome("Bo").message, slug: "bare")
    SnapshotUI::Snapshot.publish_snapshots_in_progress

    assert_equal "mail", SnapshotUI::Snapshot.find("bare").type
  end
end
