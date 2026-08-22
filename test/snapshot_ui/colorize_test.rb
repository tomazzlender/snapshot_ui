# frozen_string_literal: true

require_relative "../test_helper"
require "stringio"

class SnapshotUI::ColorizeTest < Minitest::Spec
  let(:terminal) { Object.new.tap { |io| io.define_singleton_method(:tty?) { true } } }
  let(:pipe) { StringIO.new }

  def with_env(values)
    previous = values.keys.to_h { |key| [key, ENV[key]] }
    values.each { |key, value| ENV[key] = value }
    yield
  ensure
    previous.each { |key, value| ENV[key] = value }
  end

  it "colours output written to a terminal" do
    with_env("NO_COLOR" => nil) do
      _(SnapshotUI::Colorize.red("oops", io: terminal)).must_equal "\e[31moops\e[0m"
      _(SnapshotUI::Colorize.green("fine", io: terminal)).must_equal "\e[32mfine\e[0m"
    end
  end

  it "leaves output alone when it isn't written to a terminal" do
    with_env("NO_COLOR" => nil) do
      _(SnapshotUI::Colorize.red("oops", io: pipe)).must_equal "oops"
    end
  end

  it "leaves output alone when NO_COLOR is set" do
    with_env("NO_COLOR" => "1") do
      _(SnapshotUI::Colorize.red("oops", io: terminal)).must_equal "oops"
    end
  end
end
