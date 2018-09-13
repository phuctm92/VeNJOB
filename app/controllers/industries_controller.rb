class IndustriesController < ApplicationController
  def index
    @industries = Industry.count()
  end
end