class Query < ApplicationRecord
  serialize :analytics, Hash
  validates :address, presence: true, format: { with: /.France/,
    message: "Enter  french address" }
  validates :activity, presence: true, format: { with: /./,
    message: "Enter  an activity" }
  validates :radius_search, presence: true
  validates :radius_catchment_area, presence: true

  has_many :competitors ,dependent: :destroy
  belongs_to :user

  geocoded_by :address
  after_validation :geocode, if: :address_changed?
end
