class TilesController < ApplicationController
  def index
    polygones = Tiles.perform([params[:lat1].to_f, params[:lng1].to_f],[params[:lat2].to_f, params[:lng2].to_f], params[:zoom].to_i)
    render json: polygones
  end
end
