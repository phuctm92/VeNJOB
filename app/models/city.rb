class City < ApplicationRecord
  has_many :jobs

  scope :with_counts, -> {
    select <<~SQL
      cities.*,
      (
        SELECT COUNT(jobs.id) FROM jobs
        WHERE city_id = cities.id
      ) AS jobs_count
    SQL
  }

end
