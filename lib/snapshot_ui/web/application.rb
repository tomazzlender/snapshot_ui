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

      def snapshot_title(snapshot)
        title = snapshot.context.name.sub("test_", "").gsub(/^\d{4}\s*/, "").tr("_", " ")
        suffix =
          if snapshot.context.take_snapshot_index > 0
            " (##{snapshot.context.take_snapshot_index + 1} in the same test)"
          end

        "#{title}#{suffix}"
      end

      def test_group_title(test_group)
        parts = test_group.split("::")
        last_part = "<span class='last'>#{parts.last}</span>"
        all = parts[0..-2] << last_part

        all.join(" <span class='divider'>/</span> ")
      end

      def copy_icon_svg
        <<~HTML
          <svg class="copy icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512">
            <!--!Font Awesome Free 6.6.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2024 Fonticons, Inc.-->
            <path fill="currentColor" d="M384 336l-192 0c-8.8 0-16-7.2-16-16l0-256c0-8.8 7.2-16 16-16l140.1 0L400 115.9 400 320c0 8.8-7.2 16-16 16zM192 384l192 0c35.3 0 64-28.7 64-64l0-204.1c0-12.7-5.1-24.9-14.1-33.9L366.1 14.1c-9-9-21.2-14.1-33.9-14.1L192 0c-35.3 0-64 28.7-64 64l0 256c0 35.3 28.7 64 64 64zM64 128c-35.3 0-64 28.7-64 64L0 448c0 35.3 28.7 64 64 64l192 0c35.3 0 64-28.7 64-64l0-32-48 0 0 32c0 8.8-7.2 16-16 16L64 464c-8.8 0-16-7.2-16-16l0-256c0-8.8 7.2-16 16-16l32 0 0-48-32 0z"/>
          </svg>
        HTML
      end
    end
  end
end
