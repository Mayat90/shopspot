class CitiesController < ApplicationController
  before_action :authenticate_user!
    before_action :set_query
  def index
    @cities = City.near([@query.latitude, @query.longitude], 15).first(10)
  end

  private

  def set_query
    @query = Query.find(params[:query_id])
  end
end
