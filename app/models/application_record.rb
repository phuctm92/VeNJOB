class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.solr_connection
    solr ||= RSolr.connect(url: Settings.solr.url)
  end

  def self.count(table, limit, attribute)
    solr = ApplicationRecord.solr_connection
    response = solr.get 'select', params: {
      'facet.field': "#{attribute}_id",
      facet: 'on',
      'facet.limit': "#{limit}",
      q: '*:*'
    }
    
    result = Hash[response['facet_counts']['facet_fields']["#{attribute}_id"].each_slice(2).to_a]
    query = table.where(id: result.keys).pluck(:id, :name).to_h
    test = []
    result.each do |k,v|
      test << {id: k, name: query[k.to_i], count: v}
    end
    test
  end
end

 