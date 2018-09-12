class CitiesController < ApplicationController
  def index
    @vn_cities = City.with_counts.having('jobs_count >= 1').domestic
    @inter_cities = City.with_counts.having('jobs_count >= 1').international
    @vietnam = City.domestic
    @international = City.international
  end
end