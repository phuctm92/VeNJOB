class HomeController < ApplicationController
  def index
    @total_jobs = Job.total_jobs
    @latest_jobs = Job.latest_jobs
    @cities = ApplicationRecord.count(City, Settings.constant.FACET_LIMIT, 'city')
    @industries = ApplicationRecord.count(Industry, Settings.constant.FACET_LIMIT, 'industry')
  end
end