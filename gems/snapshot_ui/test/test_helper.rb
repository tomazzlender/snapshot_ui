# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "snapshot_ui"
require "minitest/autorun"
require "minitest/focus"
require_relative "dummy/config/snapshot_ui_initializer"
