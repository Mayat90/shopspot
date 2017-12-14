module StreetViewHelper

  def street_view(query, options = {})
    params = {
      location: [query.latitude, query.longitude].join(","),
      size: "380x563",
      key: ENV['GOOGLE_API_BROWSER_KEY']
      }#.merge(options)


    query_string =  params.map{|k,v| "#{k}=#{v}"}.join("&")
    image_tag "http://maps.googleapis.com/maps/api/streetview?#{query_string}", options
  end
end
