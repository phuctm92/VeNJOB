class AddCityRefToJobs < ActiveRecord::Migration[5.2]
  def change
    add_reference :jobs, :city, foreign_key: true, index: true
  end
end
