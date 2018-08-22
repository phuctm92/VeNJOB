class AddCompanyRefToJobs < ActiveRecord::Migration[5.2]
  def change
    add_reference :jobs, :company, foreign_key: true, index: true
  end
end
