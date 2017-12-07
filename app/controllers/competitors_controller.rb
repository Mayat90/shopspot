class CompetitorsController < ApplicationController
  before_action :set_query, only: [:index]

  def index
    @competitors = Competitor.where(query_id: @query.id)
    find_details(@competitors)
    @competitors = Competitor.where(query_id: @query.id)
  end

  def find_details(competitors)
    competitors.each do |competitor|
    url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=#{competitor.place_id}=#{ENV['GOOGLE_API_BROWSER_KEY']}"
    result_search = RestClient.get(url)
    results = JSON.parse(result_search)

      results.each do |result|
        competitor.phone_number = result["result"]["formatted_phone_number"]
        competitor.address = result["result"]["formatted_address"]
        competitor.opening_hours = result["result"]["weekday_text"]
        competitor.rating = result["result"]["rating"]
        competitor.number_rating = result["result"]["reviews"].count
        competitor.update
      end
    end
  end

  private

  def set_query
    @query = Query.find(params[:query_id])
  end
end
