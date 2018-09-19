class JobsController < ApplicationController
  def index
    if params[:search].present?
      @total = Job.search_by_keyword(params[:search])['response']['numFound']
      @jobs = Kaminari.paginate_array(Job.search_by_keyword(params[:search])['response']['docs'], total_count: @total).page(params[:page]).per(20)
      @keyword = params[:search]
    else
      @total = Job.search_by_keywords(params[:title], params[:salary], params[:city_id], params[:industry_id])['response']['numFound']
      @jobs = Kaminari.paginate_array(Job.search_by_keywords(params[:title], params[:salary], params[:city_id], params[:industry_id])['response']['docs'], total_count: @total).page(params[:page]).per(20)
      @keyword = "#{params[:title]} - #{City.find(params[:city_id]).name} - 
                  #{Job.salary_options[params[:salary].to_sym]} - 
                  #{Industry.find(params[:industry_id]).name}"
    end

    @select_city = City.all
    @select_industry = Industry.all
  end

  def show
    @job = Job.find(params[:id])
  end

  def city
    @jobs = Kaminari.paginate_array(City.search_by_city(params[:id])['response']['docs'], total_count: @total).page(params[:page]).per(20)
    @total = City.search_by_city(params[:id])['response']['numFound']
    @keyword = City.find(params[:id]).name
    render :index
  end

  def industry
    @jobs = Kaminari.paginate_array(Industry.search_by_industry(params[:id])['response']['docs'], total_count: @total).page(params[:page]).per(20)
    @total = Industry.search_by_industry(params[:id])['response']['numFound']
    @keyword = Industry.find(params[:id]).name
    render :index
  end

end