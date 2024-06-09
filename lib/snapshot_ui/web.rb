# frozen_string_literal: true

require "erb"

module SnapshotUI
  class Web
    def call(_env)
      render "snapshots/index", status: 200
    end

    private

    def render(template, status:)
      @content = render_template(template)
      body = render_template("layout")
      headers = {"content-type" => "text/html; charset=utf-8"}

      [status, headers, [body]]
    end

    def render_template(template)
      template = File.read("#{File.dirname(__FILE__)}/web/views/#{template}.html.erb")
      erb = ERB.new(template)
      erb.result(binding)
    end
  end
end
