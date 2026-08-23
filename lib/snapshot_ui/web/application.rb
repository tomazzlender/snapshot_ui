# frozen_string_literal: true

require "erb"
require_relative "../snapshot"

module SnapshotUI
  class Web
    class Application
      def call(env)
        @request = Rack::Request.new(env)
        # Read the version before anything else, so that a publish happening while
        # the page renders is noticed by the next poll instead of being missed.
        @version = Snapshot.version

        if parse_root_path(@request.path_info)
          @grouped_by_test_class = SnapshotUI::Snapshot.grouped_by_test_case
          render("snapshots/index", status: 200)
        elsif parse_version_path(@request.path_info)
          render_version
        elsif (slug = parse_raw_snapshot_path(@request.path_info))
          @snapshot = Snapshot.find(slug)
          render_raw(@snapshot)
        elsif (slug = parse_snapshot_path(@request.path_info))
          @snapshot = Snapshot.find(slug)
          render_show(@snapshot)
        else
          render("snapshots/not_found", status: 404)
        end
      rescue SnapshotUI::Snapshot::NotFound
        render("snapshots/not_found", status: 404)
      end

      # Exposed for registered renderers (see SnapshotUI::Web.register_renderer).
      attr_reader :request, :version

      # Wraps already-rendered page HTML (a <body>…) in the shared layout and
      # returns a Rack response triple. Registered renderers use this so their
      # pages get the same chrome and live-refresh behaviour as the built-in
      # ones. The layout calls +refresh_controller+, so pass the view (self) as
      # the layout's binding context.
      def render_body_in_layout(body_html, status: 200)
        response_body = ERB.new(read_template("layout")).result(get_binding { body_html })
        [status, {"content-type" => "text/html; charset=utf-8"}, [response_body]]
      end

      private

      # Polled by the browser (assets/javascripts/controllers/refresh_controller.js)
      # to find out when the published snapshots change. Answers 304 Not Modified while the
      # client's version is still current.
      def render_version
        etag = %("#{@version}")
        headers = {"etag" => etag, "cache-control" => "no-cache"}

        if @request.get_header("HTTP_IF_NONE_MATCH") == etag
          [304, headers, []]
        else
          [200, headers.merge("content-type" => "text/plain; charset=utf-8"), [@version]]
        end
      end

      # The snapshot's page. Responses show the raw body in an iframe; other
      # types delegate to their registered renderer's #show.
      def render_show(snapshot)
        if snapshot.response?
          render("snapshots/show", status: 200)
        else
          status, headers, body = renderer_for(snapshot).show(snapshot, self)
          [status, headers, body]
        end
      end

      # The raw endpoint. Responses serve the stored body as HTML; other types
      # delegate to their registered renderer's #raw (which may honour params
      # such as which email part to serve).
      def render_raw(snapshot)
        if snapshot.response?
          [200, {"content-type" => "text/html; charset=utf-8"}, [snapshot.body]]
        else
          status, headers, body = renderer_for(snapshot).raw(snapshot, self)
          [status, headers, body]
        end
      end

      def renderer_for(snapshot)
        SnapshotUI::Web.renderer(snapshot.type) ||
          raise(SnapshotUI::Snapshot::NotFound, "No renderer registered for snapshot type `#{snapshot.type}`.")
      end

      def render(template, status:)
        rendered_view = ERB.new(read_template(template)).result(binding)
        response_body = ERB.new(read_template("layout")).result(get_binding { rendered_view })
        response_headers = {"content-type" => "text/html; charset=utf-8"}

        [status, response_headers, [response_body]]
      end

      def get_binding(&_block)
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

      def version_path
        [root_path, "version"].join("/")
      end

      def stylesheet_path(stylesheet)
        asset_path("stylesheets", stylesheet)
      end

      def javascript_path(javascript)
        asset_path("javascripts", javascript)
      end

      # Versioned, so that browsers don't keep using the assets of a previous release.
      def asset_path(directory, file)
        "#{[root_path, directory, file].join("/")}?v=#{SnapshotUI::VERSION}"
      end

      def snapshot_path(slug)
        [root_path, slug].join("/")
      end

      def raw_snapshot_path(slug)
        [root_path, "raw", slug].join("/")
      end

      def parse_snapshot_path(path)
        pattern = %r{^/(?<slug>.+)$}

        if (match = pattern.match(path))
          match[:slug]
        end
      end

      def parse_raw_snapshot_path(path)
        pattern = %r{^/raw/(?<slug>.+)$}

        if (match = pattern.match(path))
          match[:slug]
        end
      end

      def parse_root_path(path)
        path == "" || path == "/"
      end

      def parse_version_path(path)
        path == "/version"
      end

      # Wires <body> up to the Stimulus controller that keeps the page in sync with
      # the published snapshots (assets/javascripts/controllers/refresh_controller.js).
      def refresh_controller
        %(data-controller="refresh" data-refresh-url-value="#{version_path}" data-refresh-version-value="#{@version}" ) +
          %(data-action="turbo:render@window->refresh#displayStatus visibilitychange@document->refresh#check")
      end

      def snapshot_title(snapshot)
        snapshot.context.metadata[:title] || generic_snapshot_title(snapshot.context)
      end

      # A small label shown next to non-response snapshots in the list (e.g. mail).
      def snapshot_type_badge(snapshot)
        return "" if snapshot.response?

        %(<span class="type_badge type_badge_#{snapshot.type}">#{snapshot.type}</span>)
      end

      def generic_snapshot_title(context)
        title = context.name.sub("test_", "").gsub(/^\d{4}\s*/, "").tr("_", " ")
        suffix =
          if context.take_snapshot_index > 0
            " (##{context.take_snapshot_index + 1} in the same test)"
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

      # URL helpers registered renderers rely on (defined above under private).
      public :root_path, :snapshot_path, :raw_snapshot_path
    end
  end
end
