class HomeController < ApplicationController
  def index
    @total_jobs = Job.total_jobs
    @latest_jobs = Job.latest_jobs
    @cities = City.top_cities
    @industries = Industry.top_industries

    @select_city = City.all
    @select_industry = Industry.all
  end
end