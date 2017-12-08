require 'json'
require 'open-uri'
require 'pry'
require 'rest-client'

class Competitor < ApplicationRecord
  serialize :location, Hash
  serialize :opening_hours, Array
  belongs_to :query

 def self.find(hash)
    type = hash[:type]
    location = "#{hash[:location][:latitude]},#{hash[:location][:longitude]}"
    radius = hash[:radius_search]
    query_id = hash[:query_id]
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&radius=#{radius}&type=#{type}&key=#{ENV['GOOGLE_API_BROWSER_KEY']}"
    result_search = RestClient.get(url)
    results = JSON.parse(result_search)

   if results["next_page_token"].nil? == false
      sleep(1.3)
      url_2 = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=#{results["next_page_token"]}&key=#{ENV['GOOGLE_API_BROWSER_KEY']}"
      response = RestClient.get(url_2)
      results_2 = JSON.parse(response)

     if results_2["next_page_token"].nil? == false
        sleep(1.3)
        url_3 = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=#{results_2["next_page_token"]}&key=#{ENV['GOOGLE_API_BROWSER_KEY']}"
        response = RestClient.get(url_3)
        results_3 = JSON.parse(response)
      end
    end

  competitors = []
  if results.nil? == false
    results["results"].each do |result|
       competitor = Competitor.new
       competitor.query_id = query_id
       competitor.location = result["geometry"]["location"]
       competitor.place_id = result["place_id"]
       competitor.activity = hash[:type]
       competitor.save
       competitors << competitor
    end
  end
  if results_2.nil? == false
    results_2["results"].each do |result|
       competitor = Competitor.new
       competitor.query_id = query_id
       competitor.location = result["geometry"]["location"]
       competitor.place_id = result["place_id"]
       competitor.activity = hash[:type]
       competitor.save
       competitors << competitor
    end
  end
  if results_3.nil? == false
    results_3["results"].each do |result|
       competitor = Competitor.new
       competitor.query_id = query_id
       competitor.location = result["geometry"]["location"]
       competitor.place_id = result["place_id"]
       competitor.activity = hash[:type]
       competitor.save
       competitors << competitor
    end
  end
    return competitors
  end

end


