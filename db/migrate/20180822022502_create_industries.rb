class CreateIndustries < ActiveRecord::Migration[5.2]
  def change
    create_table :industries do |t|
      t.string :name
      t.timestamps
    end

    create_table :industries_jobs, id: false do |t|
      t.belongs_to :industries, index: true
      t.belongs_to :jobs, index: true
    end
  end
end
