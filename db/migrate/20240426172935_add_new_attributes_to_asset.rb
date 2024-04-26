class AddNewAttributesToAsset < ActiveRecord::Migration[7.1]
  def change
    add_column :assets, :duration, :string
    add_column :assets, :country, :string
  end
end
