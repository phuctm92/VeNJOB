class AddAreaToCity < ActiveRecord::Migration[5.2]
  def change
    add_column :cities, :domestic, :boolean, default: true
  end
end
