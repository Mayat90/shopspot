class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update, :destroy]

  # GET /queries
  # GET /queries.json
  def index

  @zoomscale = {
    z20: 1128.497220,
    z19: 2256.994440,
    z18: 4513.988880,
    z17: 9027.977761,
    z16: 18055.955520,
    z15: 36111.911040,
    z14: 72223.822090,
    z13: 144447.644200,
    z12: 288895.288400,
    z11: 577790.576700,
    z10: 1155581.153000,
    z9: 2311162.307000,
    z8: 4622324.614000,
    z7: 9244649.227000,
    z6: 18489298.450000,
    z5: 36978596.910000,
    z4: 73957193.820000,
    z3: 147914387.600000,
    z2: 295828775.300000,
    z1: 591657550.500000
  }
    session['address']= params["address"] if params["address"]
    session['type']= params["type"] if params["type"]
    session['search_coordinates'] = Geocoder.coordinates(session['address'])
    session['radius_search'] == params["radius_search"] if params["radius_search"]
    session['radius_catchment'] == params["radius_catchment"] if params["radius_catchment"]


    hash_request = {type: session['type'], radius_search: session['radius_search'], query_id: Query.last.id}
    hash_request[:location] = {latitude: session['search_coordinates'][0], longitude: session['search_coordinates'][1]}
    @competitors = Competitor.find(hash_request)

    @markers = Gmaps4rails.build_markers(@competitors) do |competitor, marker|
      marker.lat competitor.location["lat"]
      marker.lng competitor.location["lng"]
        # marker.infowindow content_info_window(user)
        # marker.infowindow render_to_string(partial: "/shared/info_window", locals: { user: user})
    end
        # marker de la recherche
        # @markers << {lat: @search_address[0], lng: @search_address[1], infowindow: "Your Search </br>#{session['address']}"}
@lat = session['search_coordinates'][0]
@lon = session['search_coordinates'][1]
@d = 0.01
@zoom = 13

@density = Tiles.find(@lat -@d, @lon - @d, @lat +@d, @lon +@d, @zoom)
p @density.count
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
    session['address'] = @query[:address]
    session['type']= @query[:activity]
    session['search_coordinates'] = Geocoder.coordinates(session['address'])
    session['radius_search'] = @query[:radius_search]
    session['radius_catchment'] = @query[:radius_catchment_area]
    @query.save
redirect_to queries_path
    # respond_to do |format|
    #   if @query.save
    #     format.html { redirect_to @query, notice: 'Query was successfully created.' }
    #     format.json { render :show, status: :created, location: @query }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @query.errors, status: :unprocessable_entity }
    #   end
    # end
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
      params.require(:query).permit(:address, :activity, :radius_search, :radius_catchment_area, :latitude, :longitude)
    end
end
