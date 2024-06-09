# frozen_string_literal: true

require "erb"
require "rack"
require "rack/static"
require_relative "web/application"

module SnapshotUI
  class Web
    def call(env)
      app =
        Rack::Builder.app do
          use Rack::Static,
            root: "#{File.dirname(__FILE__)}/web/assets",
            urls: %w[/stylesheets /javascripts]

          run Application.new
        end

      app.call(env)
    end
  end
end
