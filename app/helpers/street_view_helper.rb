module StreetViewHelper

  def street_view(query) #options = {}
    params = {
      location: [query.latitude, query.longitude].join(","),
      size: "360x600",
      key: ENV['GOOGLE_API_BROWSER_KEY']
      }#.merge(options)


    query_string =  params.map{|k,v| "#{k}=#{v}"}.join("&")
    image_tag "http://maps.googleapis.com/maps/api/streetview?#{query_string}"
  end
end
