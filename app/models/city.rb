class City < ApplicationRecord
  serialize :sexe, Hash
  serialize :age, Hash
end
