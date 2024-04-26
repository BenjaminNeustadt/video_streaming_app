class AddTracksAttributesToAsset < ActiveRecord::Migration[7.1]
  def change
    add_column :assets, :subtitle_language_codes, :string
    add_column :assets, :subtitle_names, :string
  end
end
