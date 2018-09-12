class HomeController < ApplicationController
  def index
    @total_jobs = Job.total_jobs
    @latest_jobs = Job.latest_jobs
    @cities = ApplicationRecord.top_record(City, 9, 'city')
    @industries = ApplicationRecord.top_record(Industry, 9, 'industry')
  end
end