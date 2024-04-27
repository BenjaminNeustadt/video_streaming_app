class AddTopPicksAttribute < ActiveRecord::Migration[7.1]
  def change
    add_column :assets, :top_picks, :boolean, default: false
  end
end
