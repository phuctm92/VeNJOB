class IndustriesController < ApplicationController
  def index
    @industries = Industry.with_counts.having('jobs_count >= :number', number: 1)
  end
end