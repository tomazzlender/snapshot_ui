# frozen_string_literal: true

require "erb"
require "rack/static"

module SnapshotUI
  class Web
    class Application
      def call(env)
        @env = env
        render("snapshots/index", status: 200)
      end

      def stylesheet_path(stylesheet)
        [root_path, "stylesheets", stylesheet].join("/")
      end

      def javascript_path(stylesheet)
        [root_path, "javascripts", stylesheet].join("/")
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
        @env["SCRIPT_NAME"]
      end
    end
  end
end
