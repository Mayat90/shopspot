require 'json'
require 'open-uri'

class Tiles
  attr_accessor :lat, :long, :poly, :population, :population_m2, :surface
  attr_accessor :personnes_seules, :personnes_seules_m2
  attr_accessor :res5_menages, :res5_menages_m2, :res65, :res65_m2, :res25, :res25_m2, :res15, :res15_m2
  attr_accessor :revenus, :basrevenus, :basrevenus_m2
  attr_accessor :locataires, :locataires_m2, :habcol, :habcol_m2

  def initialize(tile)
    data = {}
    @poly = tile["geometry"]["coordinates"][0]
    a = @poly[0]
    b = @poly[2]
    @long = (a[0] + b[0])/2
    @lat = (a[1] + b[1])/2

    data = tile["properties"]

    @population = data["ind_c"]
    @surface = data["surf"]
    @population_m2 = @population / data["surf"]
    @res65 = data["ind_age7"] / data["ind_r"] * 100 # 65 ans et + (% habitants)
    @res65_m2 = data["ind_age7"] / data["surf"] #65 ans et + (habitants / km&sup2;)
    @res25 = (1-data["ind_age6"] / data["ind_r"])*100 # 25 ans et - (% habitants)
    @res25_m2 = (1-data["ind_age6"] / data["ind_r"])*data["ind_r"] / data["surf"] #25 ans et - (habitants / km&sup2;)
    @res15 = ((+data["ind_age1"])+ (+data["ind_age2"])+(+data["ind_age3"])+(+data["ind_age4"]))/(+data["ind_c"])*100 #15 ans et - (% habitants)
    @res15_m2 = ((+data["ind_age1"])+ (+data["ind_age2"])+(+data["ind_age3"])+(+data["ind_age4"]))/(+data["surf"]) #15 ans et - (habitants / km&sup2;)
    @revenus = data["ind_srf"] / data["ind_c"] if data["ind_srf"] != "NA" #Revenus (&euro;)
    @basrevenus = data["men_basr"] / data["men"]*100 #Bas revenus (% ménages)
    @basrevenus_m2 = data["men_basr"] / data["surf"] #Bas revenus (ménages / km&sup2;)
  end

  def self.perform(center, zoom)
    radius = convertZoomToRadius(zoom)
    zoom = 14
    zoom = 11 if radius > 3000
    zoom = 10 if radius > 5000
    zoom = 9 if radius > 10000
    zoom = 8 if radius > 20000
    zoom = 7 if radius > 40000
    zoom = 6 if radius > 90000

    delta = convertradiustolatlon(radius)
    cometiesXYs = findCometiesXYs(center, delta, zoom)

    polyjson = []
    # polyjson << {
    #       paths: [
    #         {lat: center[0]+delta[:dlat], lng: center[1]-delta[:dlon]},
    #         {lat: center[0]-delta[:dlat], lng: center[1]-delta[:dlon]},
    #         {lat: center[0]-delta[:dlat], lng: center[1]+delta[:dlon]},
    #         {lat: center[0]+delta[:dlat], lng: center[1]+delta[:dlon]}
    #     ],
    #       strokeColor: '#FF0000',
    #       strokeOpacity: 0.8,
    #       strokeWeight: 1,
    #       fillColor: '#FF0000',
    #       fillOpacity: 0.2,
    #       id: "coucou"
    #     }.to_json


    tiles = []

    (cometiesXYs[:xtile_start]..cometiesXYs[:xtile_end]).each do |x|
      (cometiesXYs[:ytile_start]..cometiesXYs[:ytile_end]).each do |y|
        result = load_tiles(x, y, zoom)
        if result
          result.each do |tile|
            til = Tiles.new(tile)
            color = "#0000#{setcolor(til.population)}"
            tiles << til
            polygone = {
              paths: [],
              strokeWeight: 0,
              fillColor: color,
              fillOpacity: 0.3,
              population: til.population,

            }
            til.poly.each do |pol|
              polygone[:paths] << {lat: pol[1], lng: pol[0] }
            end
            polyjson << polygone.to_json
          end
        end
      end
    end


        return {tiles: tiles, poly: polyjson}
  end

private

  def self.convertZoomToRadius(zoom)
  @zoomscale = [
    1128.497220,
    2256.994440,
    4513.988880,
    9027.977761,
    18055.955520,
    36111.911040,
    72223.822090,
    144447.644200,
    288895.288400 * 1.6,
    577790.576700 * 1.5,
    1155581.153000,
    2311162.307000 * 1.5,
    4622324.614000,
    9244649.227000,
    18489298.450000,
    36978596.910000,
    73957193.820000,
    147914387.600000,
    295828775.300000,
    591657550.500000,
    591657550.500000
  ]
  @zoomscale.reverse!
  radius = (@zoomscale[zoom]/100).round

  return radius
  end

  def self.setcolor(popu)

    pop = (popu * 255 / 1000).round
    p pop
    pop = 0 if pop < 0
    pop = 255 if pop > 255
    pops = pop.to_i.to_s(16)
    pops = "ff" if pops.length > 2
    pops = "0" + pops if pops.length < 2

    return pops
  end

  def self.findCometiesXYs (center, delta, zoom)
    zoom = 14 if zoom > 14
d = 2
    lat1 = center[0]+(delta[:dlat] * d)
    long1 = center[1]-(delta[:dlon] * d)
    lat2 = center[0]-(delta[:dlat] * d)
    long2 = center[1]+(delta[:dlon] * d)

    tab1 = deg2num(lat1, long1, zoom)
    tab2 = deg2num(lat2, long1, zoom)
    tab3 = deg2num(lat1, long2, zoom)
    tab4 = deg2num(lat2, long2, zoom)

    find_extrem(tab1, tab2, tab3, tab4)
  end

  def self.convertradiustolatlon(radius)
    dlat = 1.0 * radius / 110574 # Latitude: 1 deg = 110.574 km
    dlon = 1.0 * radius / 111320 / 0.70716781 # Longitude: 1 deg = 111.320*cos(latitude) km
    return {dlat: dlat, dlon: dlon}

  end

  def self.deg2num (lat_deg, lon_deg, zoom)
    pi = Math::PI
    lat_rad = lat_deg * pi /180
    n = 2 ** zoom
    xtile = ((lon_deg + 180.0) / 360.0 * n).floor
    ytile = ((1.0 - Math.log(Math.tan(lat_rad) + (1 / Math.cos(lat_rad))) / pi) / 2.0 * n).floor
    return {xtile: xtile, ytile: ytile, zoom: zoom}
  end

  def self.find_extrem(tab1, tab2, tab3, tab4)
    xtile_start = tab1[:xtile]
    xtile_start = tab2[:xtile] if tab2[:xtile] < tab1[:xtile]
    xtile_start = tab3[:xtile] if tab3[:xtile] < tab2[:xtile]
    xtile_start = tab4[:xtile] if tab4[:xtile] < tab3[:xtile]

    xtile_end = tab1[:xtile]
    xtile_end = tab2[:xtile] if tab2[:xtile] > tab1[:xtile]
    xtile_end = tab3[:xtile] if tab3[:xtile] > tab2[:xtile]
    xtile_end = tab4[:xtile] if tab4[:xtile] > tab3[:xtile]

    ytile_start = tab1[:ytile]
    ytile_start = tab2[:ytile] if tab2[:ytile] < tab1[:ytile]
    ytile_start = tab3[:ytile] if tab3[:ytile] < tab2[:ytile]
    ytile_start = tab4[:ytile] if tab4[:ytile] < tab3[:ytile]

    ytile_end = tab1[:ytile]
    ytile_end = tab2[:ytile] if tab2[:ytile] > tab1[:ytile]
    ytile_end = tab3[:ytile] if tab3[:ytile] > tab2[:ytile]
    ytile_end = tab4[:ytile] if tab4[:ytile] > tab3[:ytile]
    return {xtile_start: xtile_start, xtile_end: xtile_end, ytile_start: ytile_start, ytile_end: ytile_end}
  end

  def self.load_tiles (x, y, zoom)
    url = "http://www.comeetie.fr/galerie/francepixels/SP50/#{zoom}/#{x}/#{y}.geojson"
    begin
      datas = open(url).read
    rescue
      return false
    else
      data = JSON.parse(datas)
      return data["features"]
    end
  end

end
