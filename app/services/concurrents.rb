require 'json'
require 'open-uri'
require 'pry'
require 'rest-client'

class Concurrents

  def self.find(hash)
    type = hash[:type]
    location = "#{hash[:location][:latitude]},#{hash[:location][:longitude]}"
    radius = hash[:radius_search]
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&radius=#{radius}&type=#{type}&key=#{ENV['GOOGLE_API_BROWSER_KEY']}"
    p url
    result_search = RestClient.get(url)
    results = JSON.parse(result_search)

    # if results["next_page_token"].nil? == false
    #   sleep(1.3)
    #   url_2 = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=#{results["next_page_token"]}&key=#{ENV['GOOGLE_API_BROWSER_KEY']}"
    #   response = RestClient.get(url_2)
    #   results_2 = JSON.parse(response)

    #   if results_2["next_page_token"].nil? == false
    #     sleep(1.3)
    #     url_3 = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=#{results_2["next_page_token"]}&key=#{ENV['GOOGLE_API_BROWSER_KEY']}"
    #     response = RestClient.get(url_3)
    #     results_3 = JSON.parse(response)
    #   end
    # end


    # binding.pry
  array = []
  if results.nil? == false
    results["results"].each do |result|
       array << result
    end
  end
  # if results_2.nil? == false
  #   results_2["results"].each do |result|
  #      array << result
  #   end
  # end
  # if results_3.nil? == false
  #   results_3["results"].each do |result|
  #      array << result
  #   end
  # end

  #   return array
  end
end
