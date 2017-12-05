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
    @revenus = data["ind_srf"] / data["ind_c"] #Revenus (&euro;)
    @basrevenus = data["men_basr"] / data["men"]*100 #Bas revenus (% ménages)
    @basrevenus_m2 = data["men_basr"] / data["surf"] #Bas revenus (ménages / km&sup2;)
  end

  def self.find(lat1, long1, lat2, long2, zoom)
    tab1 = deg2num(lat1, long1, zoom)
    tab2 = deg2num(lat2, long1, zoom)
    tab3 = deg2num(lat1, long2, zoom)
    tab4 = deg2num(lat2, long2, zoom)

    data = find_extrem(tab1, tab2, tab3, tab4)
    tiles = []

    (data[:xtile_start]..data[:xtile_end]).each do |x|
      (data[:ytile_start]..data[:ytile_end]).each do |y|
        result = load_tiles(x, y, zoom)
        if result
          result.each do |tile|
            tiles << Tiles.new(tile)
          end
        end
      end
    end
    return tiles
  end

private

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
