class CitiesController < ApplicationController
  before_action :authenticate_user!
    before_action :set_query
  def index
    # @cities = City.near([@query.latitude, @query.longitude], 15).first(10)
    @mydistance = []
    10.times {@mydistance << {distance: 9999999, city: {}}}
    CSV.foreach('lib/seeds/cities.csv', encoding: 'utf-8') do |row|

      @mydistance=@mydistance.sort_by { |v| v[:distance]}
      long_distance = @mydistance[9][:distance]

       distance = Tiles.distance([@query.latitude, @query.longitude], [row[4].to_f,row[3].to_f])
      if distance < long_distance
        @city  = {
        name: row[0],
        insee_id: row[1].to_i,
        area: row[2].to_f,
        longitude: row[3].to_f,
        latitude: row[4].to_f,
        population: row[5].to_i,
        sexe: {homme: row[6], femme: row[7]},
        age: {jeune: row[8], adulte: row[9], senior: row[10]},
        chomage: row[11].to_f,
        revenu: row[12].to_f
         }
         @mydistance[9] = {distance: distance, city: @city}
      end
    end
    @cities = []
    @mydistance.each { |city| @cities<< city[:city] }
  end

  private

  def set_query
    @query = Query.find(params[:query_id])
  end
end
