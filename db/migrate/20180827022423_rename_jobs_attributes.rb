class RenameJobsAttributes < ActiveRecord::Migration[5.2]
  def change
    remove_column :jobs, :short_description
    rename_column :jobs, :long_description, :description
    rename_column :jobs, :expiration_date, :end_at

    add_column :jobs, :experience, :string
    add_column :jobs, :level, :string
  end
end
