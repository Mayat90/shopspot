require 'json'
require 'open-uri'

class Tiles
  attr_accessor :lat, :long, :poly, :population, :population_m2, :surface, :center
  attr_accessor :personnes_seules, :personnes_seules_m2
  attr_accessor :res5_menages, :res5_menages_m2, :res65, :res65_m2, :res25, :res25_m2, :res15, :res15_m2
  attr_accessor :revenus, :basrevenus, :basrevenus_m2
  attr_accessor :locataires, :locataires_m2, :habcol, :habcol_m2

  def initialize(tile)
    data = {}
    @poly = tile["geometry"]["coordinates"][0]
    a = @poly[0]
    b = @poly[2]
    @center = [(a[1] + b[1])/2, (a[0] + b[0])/2]
    # @long = (a[0] + b[0])/2
    # @lat = (a[1] + b[1])/2

    data = tile["properties"]

    @population = data["ind_c"]
    @surface = data["surf"]
    @population_m2 = @population / data["surf"]
    @res65 = data["ind_age7"] / data["ind_r"] * 100 # 65 ans et + (% habitants)
    @res65_m2 = data["ind_age7"] / data["surf"] #65 ans et + (habitants / km&sup2;)

    @res25 = (data["ind_age6"] / data["ind_r"])*100 # 25 ans et - (% habitants)
    @res25_m2 = (1-data["ind_age6"] / data["ind_r"])*data["ind_r"] / data["surf"] #25 ans et - (habitants / km&sup2;)
    @res15 = ((+data["ind_age1"])+ (+data["ind_age2"])+(+data["ind_age3"])+(+data["ind_age4"]))/(+data["ind_c"])*100 #15 ans et - (% habitants)
    @res15_m2 = ((+data["ind_age1"])+ (+data["ind_age2"])+(+data["ind_age3"])+(+data["ind_age4"]))/(+data["surf"]) #15 ans et - (habitants / km&sup2;)
    data["ind_srf"] != "NA" ? @revenus = data["ind_srf"] / data["ind_c"] : @revenus = 0 #Revenus (&euro;)
    @basrevenus = data["men_basr"] / data["men"]*100 #Bas revenus (% ménages)
    @basrevenus_m2 = data["men_basr"] / data["surf"] #Bas revenus (ménages / km&sup2;)
    # @menloc= (1-data["men_prop"]/(data["men"]))*100 #Locataires (% ménages)
    # @pocc5 =data["men_occ5"]/data["men*100"] #Résidants + de 5 ans (% ménages)

  end

  def self.calculate(center, radius)
    zoom = 14
    zoom = 11 if radius > 3125
    zoom = 10 if radius > 6250
    zoom = 9 if radius > 12500
    zoom = 8 if radius > 25000
    zoom = 7 if radius > 50000
    zoom = 6 if radius > 100000

    delta = convertradiustolatlon(radius)
    cometiesXYs = findCometiesXYs(center, delta, zoom)

population = 1
res65 = 0
res25 = 0
revenus = []
menloc = 0
pocc5 = 0
i = 0
    (cometiesXYs[:xtile_start]..cometiesXYs[:xtile_end]).each do |x|
      (cometiesXYs[:ytile_start]..cometiesXYs[:ytile_end]).each do |y|
        result = load_tiles(x, y, zoom)
        if result
          result.each do |tile|
            til = Tiles.new(tile)
            distance = distance(center, til.center)
            if distance < radius
              population += til.population
              res65 += til.population * til.res65 / 100
              res25 += til.population * til.res25 / 100
              # menloc += til.population * til.menloc / 100
              # pocc5 += til.population * til.pocc5 / 100
              revenus << til.revenus
              i+=1
            end
          end
        end
      end
    end
    if revenus.count > 0
      revenus = revenus.inject{ |sum, el| sum + el } / revenus.size
    else
      revenus = 0
    end
    res25 = (res25 / population * 100).round
    res65 = (res65 / population * 100).round
    menloc = (menloc / population * 100).round
    pocc5 = (pocc5 / population * 100).round
    res2565 = 100 - res25 - res65

    return {population: population.round, revenus: revenus.round,
     res25: res25, res2565: res2565, res65: res65}
  end

  def self.perform(coord1, coord2, zoom)
    zoom -= 2
    zoom = 14 if zoom > 14
    zoom = 6 if zoom < 6
    tab1 = deg2num(coord1[0], coord1[1], zoom)
    tab2 = deg2num(coord2[0], coord1[1], zoom)
    tab3 = deg2num(coord1[0], coord2[1], zoom)
    tab4 = deg2num(coord2[0], coord2[1], zoom)
    cometiesXYs = find_extrem(tab1, tab2, tab3, tab4)
    polyjson = []
    (cometiesXYs[:xtile_start]..cometiesXYs[:xtile_end]).each do |x|
      (cometiesXYs[:ytile_start]..cometiesXYs[:ytile_end]).each do |y|
        result = load_tiles(x, y, zoom)
        if result
          result.each do |tile|
            til = Tiles.new(tile)
            color = "#00#{setcolor(til.population)}00"
            polygone = {
              paths: [],
              strokeWeight: 0,
              fillColor: color,
              fillOpacity: 0.3,
              population: til.population.round,
              revenus: til.revenus.round,
              res65: til.res65.round,
              res25: til.res25.round
            }
            til.poly.each { |pol| polygone[:paths] << {lat: pol[1], lng: pol[0] } }
            polyjson << polygone
          end
        end
      end
    end
    return polyjson
  end

private

  def self.setcolor(popu)
    pop = (popu * 255 / 1000).round
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

  def self.distance (loc1, loc2)
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters
    dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
    dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg
    lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }
    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
    rm * c # Delta in meters
  end
end
