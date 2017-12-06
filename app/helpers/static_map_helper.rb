module StaticMapHelper

  def static_map_for(query) #options = {}
    params = {
      center: [query.latitude, query.longitude].join(","),
      zoom: 16,
      size: "400x600",
      # :markers => [location.lat, location.lng].join(","),
      sensor: true
      }#.merge(options)


    query_string =  params.map{|k,v| "#{k}=#{v}"}.join("&")
    image_tag "http://maps.googleapis.com/maps/api/staticmap?#{query_string}", :alt => query.radius_search
  end

end
