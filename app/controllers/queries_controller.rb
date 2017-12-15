class QueriesController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :set_query, only: [:show, :edit, :update, :destroy]

  def index
    @letters = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)
    p @letters
    @market=""
    @queries = []
    if session['address']
      @query = load_session
      # @competitors = JSON.parse(@query.competitors_json)
      if current_user
        if current_user.queries.count != 0
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
    city_name = Geocoder.search([@query.latitude, @query.longitude]).first.data["address_components"][3]["long_name"]
    city_geocoded = Geocoder.coordinates(city_name)
    @city = City.near(city_geocoded,5).first
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
    @query = Query.new
  end

  # GET /queries/1/edit
  def edit
  end

  # POST /queries
  # POST /queries.json
  def create
    @query = Query.new(query_params)
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
    end

    def load_session
      p "loading session"
       query = Query.new
       query.address = session['address']
       query.activity = session['activity']
       query.radius_search = session['radius_search'].to_i
       query.radius_catchment_area = session['radius_catchment_area'].to_i
       query.latitude = session['latitude'].to_f
       query.longitude = session['longitude'].to_f
      query.pertinence_grade = session['pertinence_grade']

       my_hash = JSON.parse(session['analytics'])
       query.analytics = my_hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
       query.competitors_json = session['competitors']
       p "session loaded"
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

