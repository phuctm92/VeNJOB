class Job < ApplicationRecord
  has_and_belongs_to_many :industries
  belongs_to :city
  belongs_to :company

  
  @solr = ApplicationRecord.solr_connection

  def self.salary_options
    { '[5000000 TO *]':  'From 5.000.000',  '[7000000 TO *]':  'From 7.000.000',
      '[10000000 TO *]': 'From 10.000.000', '[15000000 TO *]': 'From 15.000.000',
      '[20000000 TO *]': 'From 20.000.000', '[30000000 TO *]': 'From 30.000.000' }
    
  end 

  def self.total_jobs
    response = @solr.get 'select', params: {q: '*:*'}
    response['response']["numFound"]
  end

  def self.latest_jobs
    response = @solr.get 'select', params: { 
      q: '*:*',
      sort: 'job_id desc',
      fl: 'id, job_title, salary, company_id, company_name, city_id, city_name'
    }
    response['response']["docs"]
  end

  def self.search_by_keyword(keyword)
    keyword = RSolr.solr_escape("#{keyword}")

    response = @solr.get 'select', params: {
      q: "search_text:'#{keyword}' OR job_title:'#{keyword}'^2",
      fl: "id, job_title, job_description, city_id, city_name, salary",
      rows:100000
    }
  end

  def self.search_by_keywords(title, salary, city, industry)
    title = RSolr.solr_escape("#{title}")
    response = @solr.get 'select', params: {
      q: "*:*",
      fq: ["city_id: #{city}", "job_title: #{title}", "min_salary: #{salary}", "industry_id: #{industry}"],
      fl: "id, job_title, job_description, city_id, city_name, salary",
      rows:100000
    }
  end
end

