class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update, :destroy]

  # GET /queries
  # GET /queries.json
  def index
    session['address']= params["address"] if params["address"]
    session['type']= params["type"] if params["type"]
    session['search_coordinates'] = Geocoder.coordinates(session['address'])
    session['radius_search'] == params["radius_search"] if params["radius_search"]
    session['radius_catchment'] == params["radius_catchment"] if params["radius_catchment"]

    hash_request = {}
    hash_request[:type] = session['type']
    hash_request[:location] = {latitude: session['search_coordinates'][0], longitude: session['search_coordinates'][1]}
    hash_request[:radius] = session['radius_search']

    @concurrents = Concurrents.find(hash_request)

    @markers = Gmaps4rails.build_markers(@concurrents) do |concurrent, marker|
      marker.lat concurrent[:geometry][:location][:lat]
      marker.lng concurrent[:geometry][:location][:lng]
        # marker.infowindow content_info_window(user)
        # marker.infowindow render_to_string(partial: "/shared/info_window", locals: { user: user})
    end
        # marker de la recherche
        # @markers << {lat: @search_address[0], lng: @search_address[1], infowindow: "Your Search </br>#{session['address']}"}
  end

  # GET /queries/1
  # GET /queries/1.json
  def show
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

    respond_to do |format|
      if @query.save
        format.html { redirect_to @query, notice: 'Query was successfully created.' }
        format.json { render :show, status: :created, location: @query }
      else
        format.html { render :new }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
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
