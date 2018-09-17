class Industry < ApplicationRecord
  has_and_belongs_to_many :jobs
  belongs_to :category
  
  @solr = ApplicationRecord.solr_connection

  def self.count()
    response = @solr.get 'select', params: {
      'facet.field': ["industry_id", "findustry_name"],
      facet: 'on',
      'facet.mincount': 1,
      q: "*:*"
    }
    
    ind_id = response['facet_counts']['facet_fields']["industry_id"]
    ind_name = response['facet_counts']['facet_fields']["findustry_name"]
    merge = ind_id.zip(ind_name).flatten.compact.each_slice(4).map(&:uniq)
    industries = []
    merge.each do |e|
      industries << {id: e[0], name: e[1], count: e[2]}
    end
    industries
  end

  def self.top_industries()
    response = @solr.get 'select', params: {
      'facet.field': ["industry_id", "findustry_name"],
      facet: 'on',
      'facet.limit': 9,
      q: "*:*"
    }
    
    ind_id = response['facet_counts']['facet_fields']["industry_id"]
    ind_name = response['facet_counts']['facet_fields']["findustry_name"]
    merge = ind_id.zip(ind_name).flatten.compact.each_slice(4).map(&:uniq)
    industries = []
    merge.each do |e|
      industries << {id: e[0], name: e[1], count: e[2]}
    end
    industries
  end

  def self.search_by_industry(id)
    response = @solr.get 'select', params: {
      q: "industry_id:#{id}",
      fl: "id, job_title, job_description, city_id, city_name, salary",
      rows:100000
    }

    response['response']['docs']
  end
end
