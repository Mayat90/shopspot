module StaticMapHelper

  def static_map_for(query)
    params = {
      center: [query.latitude, query.longitude].join(","),
      zoom: 16,
      size: "280x515",
      # :markers => [location.lat, location.lng].join(","),
      sensor: true,
      key: ENV['GOOGLE_API_BROWSER_KEY']
      }#.merge(options)


    query_string =  params.map{|k,v| "#{k}=#{v}"}.join("&")
    "http://maps.googleapis.com/maps/api/staticmap?#{query_string}"
  end

end
