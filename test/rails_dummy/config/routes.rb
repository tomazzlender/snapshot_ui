# frozen_string_literal: true

Rails.application.routes.draw do
  mount_snapshot_ui

  get "/hello", to: "greetings#show"
end
