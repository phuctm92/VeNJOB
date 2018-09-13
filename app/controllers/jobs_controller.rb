class JobsController < ApplicationController
  def index
  end

  def show
    @job = Job.find(params[:id])
  end

  def city
    @jobs = City.search_by_city(params[:id])
    render :index
  end

  def industry
    @jobs = Industry.search_by_industry(params[:id])
    render :index
  end

  def company
    @jobs = City.search_by_city(params[:id])
    render :index
  end
end