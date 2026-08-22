# frozen_string_literal: true

require "erb"
require "rack"
require "rack/static"
require_relative "web/application"

module SnapshotUI
  class Web
    # The Rack application serving the UI: the static assets in front of
    # Application, which handles a request per instance. Built once.
    def self.app
      @app ||= Rack::Builder.app do
        use Rack::Static,
          root: "#{File.dirname(__FILE__)}/web/assets",
          urls: %w[/stylesheets /javascripts]

        run ->(env) { Application.new.call(env) }
      end
    end

    def self.call(env)
      app.call(env)
    end

    def call(env)
      self.class.call(env)
    end
  end
end
