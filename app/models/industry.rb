class Industry < ApplicationRecord
  has_and_belongs_to_many :jobs

  scope :with_counts, -> {
    select <<~SQL
      industries.*,
      (
        SELECT COUNT(jobs.id) FROM jobs
        INNER JOIN industries_jobs 
        ON jobs.id = industries_jobs.job_id
        WHERE industries_jobs.industry_id = industries.id
      ) AS jobs_count
    SQL
  }
end
