class City < ApplicationRecord
  has_many :jobs

  scope :domestic, -> { where(domestic: true) }
  scope :international, -> { where(domestic: false) }

  @solr = ApplicationRecord.solr_connection

  def self.domestic_cities(boolean)
    response = @solr.get 'select', params: {
      'facet.field': ["city_id", "fcity_name"],
      facet: 'on',
      'facet.mincount': 1,
      q: "domestic:#{boolean}"
    }
    
    c_id = response['facet_counts']['facet_fields']["city_id"]
    c_name = response['facet_counts']['facet_fields']["fcity_name"]
    merge = c_id.zip(c_name).flatten.compact.each_slice(4).map(&:uniq)
    cities = []
    merge.each do |e|
      cities << {id: e[0], name: e[1], count: e[2]}
    end
    cities
  end

  def self.top_cities()
    response = @solr.get 'select', params: {
      'facet.field': ["city_id", "fcity_name"],
      facet: 'on',
      'facet.limit': 9,
      q: "*:*"
    }
    
    c_id = response['facet_counts']['facet_fields']["city_id"]
    c_name = response['facet_counts']['facet_fields']["fcity_name"]
    merge = c_id.zip(c_name).flatten.compact.each_slice(4).map(&:uniq)
    cities = []
    merge.each do |e|
      cities << {id: e[0], name: e[1], count: e[2]}
    end
    cities
  end

  def self.search_by_city(id)
    response = @solr.get 'select', params: {
      q: "city_id:#{id}",
      fl: "id, job_title, job_description, city_id, city_name, salary",
      rows:100000
    }
  end
end
