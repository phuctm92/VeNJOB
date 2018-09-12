class City < ApplicationRecord
  has_many :jobs

  scope :domestic, -> { City.where(domestic: true) }
  scope :international, -> { City.where(domestic: false) }
  
end
