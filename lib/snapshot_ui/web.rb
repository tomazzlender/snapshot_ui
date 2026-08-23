# frozen_string_literal: true

require "erb"
require "rack"
require "rack/static"
require_relative "web/application"

module SnapshotUI
  class Web
    @renderers = {}

    # Registers a renderer for a snapshot type. A renderer responds to
    # +show(snapshot, view)+ and +raw(snapshot, view)+, each returning a Rack
    # response triple; +view+ is the Application instance, which exposes request
    # and URL helpers. snapshot_ui-rails registers one for the "mail" type.
    def self.register_renderer(type, renderer)
      @renderers[type.to_s] = renderer
    end

    def self.renderer(type)
      @renderers[type.to_s]
    end

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
