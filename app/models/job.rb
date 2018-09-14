class Job < ApplicationRecord
  has_and_belongs_to_many :industries
  belongs_to :city
  belongs_to :company

  @solr = ApplicationRecord.solr_connection

  def self.total_jobs
    response = @solr.get 'select', params: {q: '*:*'}
    response['response']["numFound"]
  end

  def self.latest_jobs
    response = @solr.get 'select', params: { 
      q: '*:*',
      sort: 'job_id desc',
      fl: 'id, job_title, salary, ccompany_id, company_name, city_id, city_name'
    }
    response['response']["docs"]
  end
end
