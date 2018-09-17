class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.solr_connection
    solr ||= RSolr.connect(url: Settings.solr.url)
  end

end

 