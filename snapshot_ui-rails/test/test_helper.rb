# frozen_string_literal: true

# Take snapshots during this suite so the plugin actually writes them.
ENV["TAKE_SNAPSHOTS"] ||= "1"
ENV["RAILS_ENV"] = "test"

require_relative "../../test/rails_dummy/config/environment"

require "rails/test_help"
require "minitest/autorun"
