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
          @snapshots = SnapshotUI::Snapshot.all
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
        rendered_view = ERB.new(read_template(template)).result(binding)
        response_body = ERB.new(read_template("layout")).result(get_binding { rendered_view })
        response_headers = {"content-type" => "text/html; charset=utf-8"}

        [status, response_headers, [response_body]]
      end

      def get_binding
        binding
      end

      def read_template(template)
        File.read(template_path(template))
      end

      def template_path(template)
        "#{File.dirname(__FILE__)}/views/#{template}.html.erb"
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
