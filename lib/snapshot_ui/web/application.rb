# frozen_string_literal: true

require "erb"
require "rack/static"
require_relative "../snapshot"
require "listen"

module SnapshotUI
  class Web
    class Application
      def call(env)
        @request = Rack::Request.new(env)

        if parse_root_path(@request.path_info)
          @grouped_by_test_class = SnapshotUI::Snapshot.grouped_by_test_case
          if @request.get_header("HTTP_ACCEPT") != "text/event-stream"
            render("snapshots/index", status: 200)
          else
            [200, {"content-type" => "text/event-stream", "cache-control" => "no-cache", "connection" => "keep-alive"}, file_event_stream(SnapshotUI.configuration.storage_directory)]
          end
        elsif (slug = parse_raw_snapshot_path(@request.path_info))
          @snapshot = Snapshot.find(slug)
          render_raw_response_body(@snapshot.body)
        elsif (slug = parse_snapshot_path(@request.path_info))
          @snapshot = Snapshot.find(slug)
          render("snapshots/show", status: 200)
        else
          render("snapshots/not_found", status: 200)
        end
      rescue SnapshotUI::Snapshot::NotFound
        render("snapshots/not_found", status: 200)
      end

      private

      def file_event_stream(directory)
        message = '<turbo-stream action="refresh"></turbo-stream>'

        Enumerator.new do |stream|
          listener = Listen.to(directory) do |_modified, _added, _removed|
            stream << "data: #{message}\n\n"
          end

          listener.start
          sleep
        rescue Puma::ConnectionError
          listener.stop
          puts "Puma::ConnectionError"
        rescue Errno::EPIPE
          listener.stop
          puts "Errno::EPIPE"
        end
      end

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
        pattern = %r{^/response/(?<slug>.+)$}

        if (match = pattern.match(path))
          match[:slug]
        end
      end

      def parse_raw_snapshot_path(path)
        pattern = %r{^/response/raw/(?<slug>.+)$}

        if (match = pattern.match(path))
          match[:slug]
        end
      end

      def parse_root_path(path)
        path == "" || path == "/"
      end

      def refresh_controller
        'data-controller="refresh" data-action="refresh-connected@window->refresh#connected refresh-disconnected@window->refresh#disconnected turbo:before-render@window->refresh#display_status"'
      end
    end
  end
end
