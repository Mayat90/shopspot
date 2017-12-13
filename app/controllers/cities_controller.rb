class CitiesController < ApplicationController
  before_action :set_query
  def index

  end

  private

  def set_query
    @query = Query.find(params[:query_id])
  end
end
