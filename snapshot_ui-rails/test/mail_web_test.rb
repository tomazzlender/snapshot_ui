# frozen_string_literal: true

require_relative "test_helper"

# The mounted UI rendering "mail" snapshots.
class MailWebTest < ActionDispatch::IntegrationTest
  setup do
    SnapshotUI.clear_snapshots
    NotifierMailer.welcome("Ada").tap { |m| take_snapshot(m, title: "Welcome email", slug: "welcome") }
    NotifierMailer.html_only.tap { |m| take_snapshot(m, slug: "html-only") }
    NotifierMailer.text_only.tap { |m| take_snapshot(m, slug: "text-only") }
    SnapshotUI::Snapshot.publish_snapshots_in_progress
  end

  teardown { SnapshotUI.clear_snapshots }

  test "the index lists mail snapshots with a type badge" do
    get "/rails/ui_snapshots"
    assert_response :success
    assert_includes @response.body, "Welcome email"
    assert_match %r{<span class="type_badge type_badge_mail">mail</span>}, @response.body
  end

  test "the mail page shows headers and a part switcher for a multipart email" do
    get "/rails/ui_snapshots/welcome"
    assert_response :success
    assert_includes @response.body, "Welcome to the waiting list"          # subject
    assert_includes @response.body, "NotifierMailer#welcome"               # mailer/action
    assert_includes @response.body, "team@example.test"                    # cc header
    assert_includes @response.body, ">HTML</a>"                            # part tabs
    assert_includes @response.body, ">Plain text</a>"
    assert_includes @response.body, "welcome.txt"                          # attachment
    assert_includes @response.body, "Download .eml"
  end

  test "the raw endpoint serves the HTML part as HTML" do
    get "/rails/ui_snapshots/raw/welcome", params: {part: "text/html"}
    assert_response :success
    assert_equal "text/html; charset=utf-8", @response.media_type + "; charset=" + @response.charset
    assert_includes @response.body, "Welcome, Ada"
  end

  test "the raw endpoint serves the text part as plain text" do
    get "/rails/ui_snapshots/raw/welcome", params: {part: "text/plain"}
    assert_response :success
    assert_equal "text/plain", @response.media_type
    assert_includes @response.body, "Browse available plots"
    refute_includes @response.body, "<h1"
  end

  test "the raw endpoint downloads the .eml file" do
    get "/rails/ui_snapshots/raw/welcome", params: {eml: "1"}
    assert_response :success
    assert_equal "message/rfc822", @response.media_type
    assert_match(/attachment; filename="NotifierMailer#welcome\.eml"/, @response.headers["content-disposition"])
    assert_includes @response.body, "Subject: Welcome to the waiting list"
  end

  test "an html-only email shows a single-part label and no switcher" do
    get "/rails/ui_snapshots/html-only"
    assert_response :success
    assert_includes @response.body, "HTML email"
    refute_includes @response.body, ">Plain text</a>"
  end

  test "requesting a missing part returns 404" do
    get "/rails/ui_snapshots/raw/text-only", params: {part: "text/html"}
    assert_response :not_found
  end
end
