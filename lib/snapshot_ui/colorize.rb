# frozen_string_literal: true

module SnapshotUI
  # Colours terminal output, unless the output isn't a terminal or NO_COLOR is set.
  module Colorize
    module_function

    def red(string, io: $stdout)
      colorize(string, 31, io: io)
    end

    def green(string, io: $stdout)
      colorize(string, 32, io: io)
    end

    def colorize(string, code, io: $stdout)
      return string unless enabled?(io)

      "\e[#{code}m#{string}\e[0m"
    end

    def enabled?(io = $stdout)
      io.respond_to?(:tty?) && io.tty? && ENV["NO_COLOR"].to_s.empty?
    end
  end
end
