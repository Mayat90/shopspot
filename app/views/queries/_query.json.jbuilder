json.extract! query, :id, :address, :activity, :radius_search, :radius_catchment_area, :latitude, :longitude, :created_at, :updated_at
json.url query_url(query, format: :json)
