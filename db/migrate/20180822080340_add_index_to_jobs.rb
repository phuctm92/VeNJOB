class AddIndexToJobs < ActiveRecord::Migration[5.2]
  def change
    add_index :jobs, :title
  end
end
