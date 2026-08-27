# frozen_string_literal: true

require_relative "boot"

require "rails"
require "action_controller/railtie"
require "action_mailer/railtie"

# Loads the snapshot_ui-rails railtie.
require "snapshot_ui-rails"

module RailsDummy
  class Application < Rails::Application
    config.load_defaults ::Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.consider_all_requests_local = true
    config.secret_key_base = "snapshot_ui_rails_dummy_secret_key_base_for_tests_only"
    config.hosts.clear
    config.logger = Logger.new(IO::NULL)
    config.action_mailer.delivery_method = :test
    config.action_mailer.default_url_options = {host: "localhost", port: 3000}
  end
end
