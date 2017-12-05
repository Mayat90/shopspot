class Query < ApplicationRecord
  validates :address, presence: true
  validates :activity, presence: true
  validates :radius_search, presence: true
  validates :radius_catchment_area, presence: true

  geocoded_by :address
  after_create :geocode, if: :address_changed?
end
