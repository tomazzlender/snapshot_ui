# frozen_string_literal: true

Rails.application.routes.draw do
  # Mounted unconditionally: this dummy app boots in the test environment, where
  # the integration suite drives the UI. A real app would guard this with
  # `if Rails.env.development?` (see the gem README).
  mount_snapshot_ui

  get "/hello", to: "greetings#show"
  get "/plots/:id", to: "plots#show"
end
