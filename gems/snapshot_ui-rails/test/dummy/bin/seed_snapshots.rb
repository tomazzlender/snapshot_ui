# frozen_string_literal: true

# Seeds the demo snapshots used by the screenshots in the README and the preview
# report. Modelled on a community-garden website so the list reads realistically.
# Run with RAILS_ENV=test TAKE_SNAPSHOTS=1.

ENV["TAKE_SNAPSHOTS"] = "1"
ENV["RAILS_ENV"] = "test"

require_relative "../config/environment"
require "snapshot_ui/rails/mail_snapshot"
require "snapshot_ui/snapshot"

SnapshotUI.clear_snapshots

def context(test_case:, method:, line:, slug:, title: nil, file: "test/integration/plots_test.rb")
  {
    test_framework: "minitest",
    test_case_name: test_case,
    method_name: method,
    source_location: [Rails.root.join(file).to_s, line],
    take_snapshot_index: 0,
    metadata: {title: title, slug: slug}
  }
end

def page(title, body)
  <<~HTML
    <!doctype html><html><head><meta charset="utf-8"><title>#{title} · Fernwood Community Garden</title>
    <style>
      body{margin:0;font-family:-apple-system,"Segoe UI",system-ui,sans-serif;color:#1f2937;background:#f2f6f2}
      header{background:linear-gradient(135deg,#166534,#15803d);color:#fff;padding:18px 32px;display:flex;gap:10px;align-items:center}
      header nav{margin-left:auto;display:flex;gap:22px;font-size:14px}header nav a{color:#dcfce7;text-decoration:none}
      .wrap{max-width:820px;margin:32px auto;padding:0 20px}
      .card{background:#fff;border-radius:14px;box-shadow:0 1px 3px rgba(0,0,0,.06);padding:28px 32px;margin:0 0 16px}
      h1{margin:0 0 12px;font-size:26px}h2{margin:0 0 4px;font-size:18px}
      .muted{color:#6b7280;font-size:14px}.badge{display:inline-block;background:#dcfce7;color:#166534;font-size:12px;font-weight:700;padding:3px 10px;border-radius:999px}
      .cta{display:inline-block;margin-top:8px;background:#15803d;color:#fff;padding:11px 22px;border-radius:8px;text-decoration:none;font-weight:600;font-size:14px}
      label{display:block;font-size:13px;color:#374151;margin:12px 0 4px}input{width:100%;padding:10px;border:1px solid #d1d5db;border-radius:8px;font-size:14px}
    </style></head>
    <body>
      <header><span style="font-size:22px">🌱</span><strong>Fernwood Community Garden</strong>
        <nav><a href="/plots">Plots</a><a href="/about">About</a><a href="/join">Join</a></nav></header>
      <div class="wrap">#{body}</div>
    </body></html>
  HTML
end

# --- Response snapshots: garden-website pages ---
plots_index = page("Available plots", <<~BODY)
  <h1>Available plots</h1>
  <div class="card"><span class="badge">Available from April</span><h2>🥕 Raised bed A3</h2><p class="muted">Full sun · 2×1m · $8 / month</p><a class="cta" href="/plots/A3">View plot</a></div>
  <div class="card"><span class="badge">Available from May</span><h2>🌿 Herb corner H1</h2><p class="muted">Partial shade · 1×1m · $5 / month</p><a class="cta" href="/plots/H1">View plot</a></div>
  <div class="card"><span class="badge">Waitlist</span><h2>🌻 Sunflower row S2</h2><p class="muted">Full sun · 3×1m · $10 / month</p><a class="cta" href="/plots/S2">Join waitlist</a></div>
BODY

reserved = page("Plot reserved", <<~BODY)
  <div class="card"><h1>Plot reserved 🎉</h1><p>Raised bed A3 is yours from April. We've emailed your confirmation and the garden gate code.</p><a class="cta" href="/plots">Back to plots</a></div>
BODY

join_form = page("Join the garden", <<~BODY)
  <div class="card"><h1>Join Fernwood</h1><p class="muted">Add your name to the community garden waiting list.</p>
    <form><label>Full name</label><input value="Ada Lovelace"><label>Email</label><input value="ada@example.test"><a class="cta" href="#">Join the waiting list</a></form></div>
BODY

SnapshotUI::Snapshot.persist(snapshotee: plots_index, type: "response",
  context: context(test_case: "PlotsTest", method: "test_lists_available_plots", line: 8, slug: "plots-index", title: "Available plots"))

# The plot detail page comes from the real controller/view.
SnapshotUI::Snapshot.persist(snapshotee: PlotsController::PLOT.then { |_| ActionController::Base.render(template: "plots/show", assigns: {plot: PlotsController::PLOT}, layout: false) },
  type: "response",
  context: context(test_case: "PlotsTest", method: "test_shows_a_plot", line: 16, slug: "plot-A3", title: "Plot detail — Raised bed A3"))

SnapshotUI::Snapshot.persist(snapshotee: reserved, type: "response",
  context: context(test_case: "PlotsTest", method: "test_reserving_a_plot", line: 27, slug: "plot-reserved", title: "Plot reserved confirmation"))

SnapshotUI::Snapshot.persist(snapshotee: join_form, type: "response",
  context: context(test_case: "MembershipsTest", method: "test_join_form", line: 6, slug: "join", title: "Join form", file: "test/integration/memberships_test.rb"))

# --- Mail snapshots ---
SnapshotUI::Rails::MailSnapshot.persist(NotifierMailer.welcome("Ada"),
  context: context(test_case: "NotifierMailerTest", method: "test_welcome", line: 6, slug: "welcome", title: "Welcome email", file: "test/mailers/notifier_mailer_test.rb"))

SnapshotUI::Rails::MailSnapshot.persist(NotifierMailer.receipt,
  context: context(test_case: "NotifierMailerTest", method: "test_receipt", line: 14, slug: "receipt", title: "Order receipt", file: "test/mailers/notifier_mailer_test.rb"))

SnapshotUI::Snapshot.publish_snapshots_in_progress
puts "Seeded #{SnapshotUI::Snapshot::Storage.list.size} snapshots: #{SnapshotUI::Snapshot::Storage.list.sort.join(", ")}"
