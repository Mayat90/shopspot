class CompetitorsController < ApplicationController
  before_action :set_query, only: [:index]

  def index
    @competitors = Competitor.where(query_id: @query)
    find_details(@competitors)
    @competitors = Competitor.where(query_id: @query).order(:rating).first(5)
  end

  def find_details(competitors)
    competitors.each do |competitor|
    url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=#{competitor.place_id}&key=#{ENV['GOOGLE_API_BROWSER_KEY']}"
    result_search = RestClient.get(url)
    results = JSON.parse(result_search)
      competitor.phone_number = results["result"]["formatted_phone_number"]
      competitor.address = results["result"]["formatted_address"]
      competitor.opening_hours = results["result"]["weekday_text"]
      competitor.rating = results["result"]["rating"]
      if results["result"]["reviews"].nil? == false
        competitor.number_rating = results["result"]["reviews"].count
      end
      competitor.save

    end
  end

  def ajax
    hash_request = {type: session['type'], radius_search: session['radius_search'], query_id: Query.last.id}
    hash_request[:location] = {latitude: session['search_coordinates'][0], longitude: session['search_coordinates'][1]}
    @competitors = Competitor.find(hash_request)
    render json: @competitors
  end

  private

  def set_query
    @query = Query.find(params[:query_id])
  end
end
