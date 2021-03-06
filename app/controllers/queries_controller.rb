require 'csv'
class QueriesController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :set_query, only: [:show, :edit, :update, :destroy]

  def index
    @query = Query.new
    @letters = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)
    @market=""
    @queries = []
    if session['address']
      @query = load_session
      # @competitors = JSON.parse(@query.competitors_json)
      if current_user
        if current_user.queries.count != -1
          @query.user = current_user
          @query.save
          p "session save to db"
        end
          session_delete
      end
    end
    if current_user
      @queries = current_user.queries.sort_by {|q| q.pertinence_grade}
      @queries.reverse!
      redirect_to root_path if @queries.count < 1
    elsif session['address']
      @query.id = 0
      @queries << @query
    else
      redirect_to root_path
    end
  end


  # GET /queries/1
  # GET /queries/1.json
  def show

    @competitors = []

    competitors_parse = JSON.parse(@query.competitors_json)
    if competitors_parse.nil? == false && @query.competitors.count == 0
      competitors_parse.each do |competitor_parse|
         competitor = Competitor.new
         competitor.query_id = @query.id
         competitor.location = {lat: competitor_parse["lat"], lng: competitor_parse["lng"] }
         competitor.place_id = competitor_parse["place_id"]
         competitor.name = competitor_parse["name"]
         competitor.activity = @query.activity
         competitor.save
         @competitors << competitor
      end
    end
    address_array = @query.address.split(', ')
    if address_array.count == 2
      city_name = address_array.join(', ')
    else
      city_name = address_array[1]
    end
    # pour les grandes villes - on peut renvoyer l'arrondissement
    # city_name = Geocoder.search([@query.latitude, @query.longitude]).first.data["address_components"][2]["long_name"]

    city_geocoded = Geocoder.coordinates(city_name)
    # p city_geocoded
    # @city = City.near(city_geocoded,5).first


    @mydistance = 9999999
CSV.foreach('lib/seeds/cities.csv', encoding: 'utf-8') do |row|
   distance = Tiles.distance(city_geocoded, [row[4].to_f,row[3].to_f])
  if distance < @mydistance
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
     @mydistance = distance
  end
end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Your market studys",
          template: "queries/pdf.html.erb",
          orientation: "Landscape",
          layout: 'pdf'
        # à mettre en forme avec Javascript tag pour garder css
      end
    end
  end
  # GET /queries/new
  def new
    if session['address']
      @query = load_session
      # @competitors = JSON.parse(@query.competitors_json)
      if current_user
        if current_user.queries.count != -1
          @query.user = current_user
          @query.save
        end
          session_delete
      end
    else

    @query = Query.new
    end
  end

  # GET /queries/1/edit
  def edit
  end

  # POST /queries
  # POST /queries.json
  def create
    @query = Query.new(query_params)

    if @query.valid?
      loc = Geocoder.coordinates(@query.address)
      @query.latitude = loc[0]
      @query.longitude = loc[1]
      hash_request = {type: @query.activity, radius_search: @query.radius_search}
      hash_request[:location] = {latitude: loc[0], longitude: loc[1]}
      @competitors_search = Competitor.find(hash_request)
      @competitors = []
      @competitors_search.each do |competitor|
        distance = Tiles.distance((loc), [competitor["lat"], competitor["lng"]])
        @competitors << competitor if distance <= @query.radius_search #competitors dans la search_area
      end
      @query.competitors_json = @competitors.to_json

      @competitors_catchment = []
      @competitors_search.each do |competitor|
        distance = Tiles.distance((loc), [competitor["lat"], competitor["lng"]])
        @competitors_catchment << competitor if distance <= @query.radius_catchment_area #competitors dans la search_area
      end
      @query.competitors_catchment = @competitors_catchment.count
      resultats_insee = Tiles.calculate([@query.latitude, @query.longitude], @query.radius_catchment_area)
      @query.analytics = resultats_insee

      if @query.competitors_catchment != 0
        pop_grade = @query.analytics[:population].fdiv(@query.competitors_catchment)
        @query.pertinence_grade = pertinence_grade(pop_grade)
      else
        @query.pertinence_grade = 0
      end

      if current_user
        @query.user = current_user
        @query.save
      else
        save_session(@query)
      end
      redirect_to queries_path
    else
      @alert= ""
      @query.errors.messages.each_key {| key |
        @alert += " #{key.to_s} #{@query.errors[key]}"
       }
      redirect_to request.path, flash: {alert: @alert}
    end
  end

  # PATCH/PUT /queries/1
  # PATCH/PUT /queries/1.json
  def update
    respond_to do |format|
      if @query.update(query_params)
        format.html { redirect_to @query, notice: 'Query was successfully updated.' }
        format.json { render :show, status: :ok, location: @query }
      else
        format.html { render :edit }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /queries/1
  # DELETE /queries/1.json
  def destroy
    @query.destroy
    redirect_to queries_path

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_query
      if params[:id] == "0"
        redirect_to queries_path
      else
        @query = Query.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def query_params
      params.require(:query).permit(:address, :activity, :radius_search, :radius_catchment_area)
    end

    def save_session(query)
      session['address'] = query.address
      session['activity']= query.activity
      session['radius_search'] = query.radius_search
      session['radius_catchment_area'] = query.radius_catchment_area
      session['latitude'] = query.latitude
      session['longitude'] = query.longitude
      session['analytics'] = query.analytics.to_json
      session['competitors'] = query.competitors_json
      session['pertinence_grade'] = query.pertinence_grade
      session['competitors_catchment'] = query.competitors_catchment
    end

    def load_session
       query = Query.new
       query.address = session['address']
       query.activity = session['activity']
       query.radius_search = session['radius_search'].to_i
       query.radius_catchment_area = session['radius_catchment_area'].to_i
       query.latitude = session['latitude'].to_f
       query.longitude = session['longitude'].to_f
      query.pertinence_grade = session['pertinence_grade']
      query.competitors_catchment = session['competitors_catchment']
       my_hash = JSON.parse(session['analytics'])
       query.analytics = my_hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
       query.competitors_json = session['competitors']
       query
    end

    def session_delete
      session.delete('address')
      session.delete('activity')
      session.delete('radius_search')
      session.delete('radius_catchment_area')
      session.delete('latitude')
      session.delete('longitude')
      session.delete('analytics')
      session.delete('competitors')
    end

    def pertinence_grade(number)
      if number < 50
        return 0
      elsif number < 100
        return 1
      elsif number < 200
        return 2
      elsif number < 500
        return 3
      elsif number < 900
        return 4
      else
        return 5
      end
    end
end

