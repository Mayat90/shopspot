class Query < ApplicationRecord
  geocoded_by :address
  after_create :geocode, if: :address_changed?
end
