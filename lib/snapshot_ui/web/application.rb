# frozen_string_literal: true

require "erb"
require "rack/static"
require_relative "../snapshot"

module SnapshotUI
  class Web
    class Application
      def call(env)
        @request = Rack::Request.new(env)

        case @request.path_info
        when ""
          render("snapshots/index", status: 200)
        when "/sample-test-case-one"
          render("snapshots/show", status: 200)
        else
          render("snapshots/not_found", status: 200)
        end
      end

      private

      def render(template, status:)
        @content = render_template(template)
        body = render_template("layout")
        headers = {"content-type" => "text/html; charset=utf-8"}

        [status, headers, [body]]
      end

      def render_template(template)
        template = File.read("#{File.dirname(__FILE__)}/views/#{template}.html.erb")
        erb = ERB.new(template)
        erb.result(binding)
      end

      def root_path
        @request.env["SCRIPT_NAME"]
      end

      def stylesheet_path(stylesheet)
        [root_path, "stylesheets", stylesheet].join("/")
      end

      def javascript_path(stylesheet)
        [root_path, "javascripts", stylesheet].join("/")
      end

      def snapshot_path(slug)
        [root_path, slug].join("/")
      end

      def list_snapshots
        SnapshotUI::Snapshot.all
      end
    end
  end
end
