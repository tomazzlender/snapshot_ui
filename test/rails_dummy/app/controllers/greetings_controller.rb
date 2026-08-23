# frozen_string_literal: true

class GreetingsController < ActionController::Base
  def show
    render html: "<h1>Hello from Rails</h1>".html_safe, layout: false
  end
end
