class Query < ApplicationRecord
  validates :address, presence: true
  validates :activity, presence: true
  validates :radius_search, presence: true
  validates :radius_catchment_area, presence: true

end
