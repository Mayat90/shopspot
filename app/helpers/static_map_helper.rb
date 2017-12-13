module StaticMapHelper

  def static_map_for(query) #options = {}
    params = {
      center: [query.latitude, query.longitude].join(","),
      zoom: 16,
      size: "260x600",
      # :markers => [location.lat, location.lng].join(","),
      sensor: true,
      key: ENV['GOOGLE_API_BROWSER_KEY']
      }#.merge(options)


    query_string =  params.map{|k,v| "#{k}=#{v}"}.join("&")
    image_tag "http://maps.googleapis.com/maps/api/staticmap?#{query_string}", :alt => query.radius_search
  end

end
