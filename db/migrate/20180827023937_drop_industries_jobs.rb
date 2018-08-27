class DropIndustriesJobs < ActiveRecord::Migration[5.2]
  def change
    drop_table :industries_jobs
  end
end
