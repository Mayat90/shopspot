require 'json'
require 'open-uri'

class PagesController < ApplicationController
  def home
  end

  def about
  end

  def insee
    lat = params["lat"].to_f
    long = params["long"].to_f
    zoom = params["zoom"].to_i
    delta = 0.01

    @tiles= Tiles.find(lat-delta, long-delta, lat + delta, long + delta, zoom)

  end

end
