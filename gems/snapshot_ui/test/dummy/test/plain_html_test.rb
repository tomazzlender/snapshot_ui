# frozen_string_literal: true

require "erb"
require "nokogiri"
require_relative "../../test_helper"
require_relative "../../../lib/snapshot_ui/test/minitest_helpers"

class PlainHtmlTest < Minitest::Test
  include SnapshotUI::Test::MinitestHelpers

  module DummyUIComponentLibrary
    module_function

    def button(text:)
      '<button class="inline-flex justify-center rounded-lg text-sm font-semibold py-3 px-4 bg-slate-900 text-white hover:bg-slate-700">' + text + "</button>"
    end
  end

  module PreviewLayout
    module_function

    def render(content)
      layout = ERB.new <<~HTML
        <!doctype html>
        <html>
        <head>
          <meta charset="UTF-8">
          <script src="https://cdn.tailwindcss.com"></script>
        </head>
        <body class="grid place-content-center h-screen">
          <%= content %>
        </body>
        </html>
      HTML

      layout.result(binding)
    end
  end

  def test_example_button_component
    example_button_component = DummyUIComponentLibrary.button(text: "Click me!")

    take_snapshot(PreviewLayout.render(example_button_component), title: "Primary Button", slug: "primary-button")

    assert_equal "Click me!", Nokogiri::HTML(example_button_component).at_css("button").text
  end
end
