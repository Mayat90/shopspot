class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: :show

  def index
    @queries = []
    if session['address']
      @query = load_session
      @query.id = 0
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
      @queries = current_user.queries.reverse
    elsif session['address']
      @queries << @query
    else
      redirect_to root_path
    end
  end


  # GET /queries/1
  # GET /queries/1.json
  def show
    competitors_parse = JSON.parse(@query.competitors_json)
    if competitors_parse.nil? == false
      competitors_parse.each do |competitor_parse|
         competitor = Competitor.new
         # competitor.query_id = @query.id
         competitor.location = {lat: competitor_parse["lat"], lng: competitor_parse["lng"] }
         competitor.place_id = competitor_parse["place_id"]
         competitor.name = competitor_parse["name"]
         competitor.activity = @query.activity
         competitor.save
         competitors << competitor
      end
    end
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Your market studys",
          template: "queries/show.html.erb"
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
    resultats_insee = Tiles.calculate([@query.latitude, @query.longitude], @query.radius_catchment_area)
    @query.analytics = resultats_insee

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
    respond_to do |format|
      format.html { redirect_to queries_url, notice: 'Query was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_query
      @query = Query.find(params[:id])
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

end

