class Query < ApplicationRecord
  serialize :analytics, Hash
  validates :address, presence: true
  validates :activity, presence: true
  validates :radius_search, presence: true
  validates :radius_catchment_area, presence: true
  has_many :competitors
  belongs_to :user

  geocoded_by :address
  after_validation :geocode, if: :address_changed?
end
