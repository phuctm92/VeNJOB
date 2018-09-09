class HomeController < ApplicationController
  def index
    @total_jobs = Job.count
    @latest_jobs = Job.includes(:company, :city).order(created_at: :desc).limit(9)
    @cities = City.with_counts.order('jobs_count DESC').limit(9)
    @industries = Industry.with_counts.order('jobs_count DESC').limit(9)
  end
end