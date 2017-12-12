class City < ApplicationRecord

  reverse_geocoded_by :latitude, :longitude
  serialize :sexe, Hash
  serialize :age, Hash
end
