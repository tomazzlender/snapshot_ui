# frozen_string_literal: true

require "erb"
require "rack/static"
require_relative "../snapshot"

module SnapshotUI
  class Web
    class Application
      def call(env)
        @request = Rack::Request.new(env)

        if parse_root_path(@request.path_info)
          render("snapshots/index", status: 200)
        elsif (slug = parse_raw_snapshot_path(@request.path_info))
          response_body = SnapshotUI::Snapshot.read_response_body(slug)
          render_raw_response_body(response_body)
        elsif (slug = parse_snapshot_path(@request.path_info))
          @slug = slug
          render("snapshots/show", status: 200)
        else
          render("snapshots/not_found", status: 200)
        end
      end

      private

      def render_raw_response_body(response_body)
        [200, {"content-type" => "text/html; charset=utf-8"}, [response_body]]
      end

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
        [root_path, "response", slug].join("/")
      end

      def raw_snapshot_path(slug)
        [root_path, "response", "raw", slug].join("/")
      end

      def list_snapshots
        SnapshotUI::Snapshot.all
      end

      def parse_snapshot_path(path)
        match = path.match(/\/response\/([^\/]+)/)
        _slug = match[1] if match
      end

      def parse_raw_snapshot_path(path)
        match = path.match(/\/response\/raw\/([^\/]+)/)
        _slug = match[1] if match
      end

      def parse_root_path(path)
        path == ""
      end
    end
  end
end
