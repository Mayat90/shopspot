require 'json'
require 'open-uri'
require 'rest-client'

class Competitor < ApplicationRecord
  serialize :location, Hash
  serialize :opening_hours, Array
  belongs_to :query

 def self.find(hash)
    type = hash[:type]
    location = "#{hash[:location][:latitude]},#{hash[:location][:longitude]}"
    radius = hash[:radius_search]

    competitors = []

    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&rankby=distance&type=#{type}&key=#{ENV['GOOGLE_API_BROWSER_KEY']}"
    result_search = RestClient.get(url)
    results = JSON.parse(result_search)
    results["results"].each do |result|
      competitors << {
        "lat" => result["geometry"]["location"]["lat"],
        "lng" => result["geometry"]["location"]["lng"],
        "name" => result["name"],
        "place_id" => result["place_id"]
      }
    end

   if results["next_page_token"].nil? == false
      sleep(1.4)
      url_2 = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=#{results["next_page_token"]}&key=#{ENV['GOOGLE_API_BROWSER_KEY']}"
      response = RestClient.get(url_2)
      results_2 = JSON.parse(response)
      results_2["results"].each do |result|
        competitors << {
          "lat" => result["geometry"]["location"]["lat"],
          "lng" => result["geometry"]["location"]["lng"],
          "name" => result["name"],
          "place_id" => result["place_id"]
        }
      end
    end

    if results_2["next_page_token"].nil? == false
      sleep(1.4)
      url_3 = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=#{results_2["next_page_token"]}&key=#{ENV['GOOGLE_API_BROWSER_KEY']}"
      response = RestClient.get(url_3)
      results_3 = JSON.parse(response)
      results_3["results"].each do |result|
        competitors << {
          "lat" => result["geometry"]["location"]["lat"],
          "lng" => result["geometry"]["location"]["lng"],
          "name" => result["name"],
          "place_id" => result["place_id"]
        }
      end
    end
    return competitors
  end
end

