# frozen_string_literal: true

module SnapshotUI
  module Colorize
    module_function

    def red(string)
      "\e[31m#{string}\e[0m"
    end

    def green(string)
      "\e[32m#{string}\e[0m"
    end
  end
end
