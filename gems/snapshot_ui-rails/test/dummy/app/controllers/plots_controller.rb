# frozen_string_literal: true

class PlotsController < ActionController::Base
  append_view_path File.expand_path("../views", __dir__)

  PLOT = {
    id: "A3",
    name: "Raised bed A3",
    sun: "Full sun",
    size: "2×1m",
    price: "$8 / month",
    available_from: "April",
    description: "A generous raised bed in the sunniest corner of the Fernwood Community Garden — ideal for tomatoes, peppers and courgettes."
  }.freeze

  def show
    @plot = PLOT
    render :show, layout: false
  end
end
