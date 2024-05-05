class AddLongAndLatToUserData < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :longitude, :string
    add_column :users, :latitude, :string
  end
end
