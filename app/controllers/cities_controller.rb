class CitiesController < ApplicationController
  def index
    @vn_cities = City.domestic_cities(true)
    @inter_cities = City.domestic_cities(false)
    @vietnam = City.domestic
    @international = City.international
  end
end