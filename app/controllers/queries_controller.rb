class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update, :destroy]

  # GET /queries
  # GET /queries.json
  def index
    # session['address']= params["address"] if params["address"]
    # session['type']= params["type"] if params["type"]
    # session['search_coordinates'] = Geocoder.coordinates(session['address'])
    # session['radius_search'] = params["radius_search"] if params["radius_search"]
    # session['radius_catchment'] = params["radius_catchment"] if params["radius_catchment"]

# session['address'] ? (@query = load_session) : redirect_to new

@query = load_session
@competitors = JSON.parse(@query.competitors_json)
    @markers = Gmaps4rails.build_markers(@competitors) do |competitor, marker|
      marker.lat competitor["lat"]
      marker.lng competitor["lng"]
        # marker.infowindow content_info_window(user)
        # marker.infowindow render_to_string(partial: "/shared/info_window", locals: { user: user})
    end
        # marker de la recherche
        # @markers << {lat: @search_address[0], lng: @search_address[1], infowindow: "Your Search </br>#{session['address']}"}
    # @query = Query.last

  end


  # GET /queries/1
  # GET /queries/1.json
  def show
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
      distance = Tiles.distance((loc), [competitor.location["lat"], competitor.location["lng"]])
      @competitors << {"name" => competitor.name, "place_id" => competitor.place_id, "lat" => competitor.location["lat"], "lng" => competitor.location["lng"]} if distance <= @query.radius_search #competitors dans la search_area
    end
    @query.competitors_json = @competitors.to_json
    resultats_insee = Tiles.calculate([@query.latitude, @query.longitude], @query.radius_catchment_area)
    @query.analytics = resultats_insee

save_session(@query)
    # @query.save
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
       query.['query_id'] = 0
       p "session loaded"
       query
    end
end
