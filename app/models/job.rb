class Job < ApplicationRecord
  has_and_belongs_to_many :industries
  belongs_to :city
  belongs_to :company
end
