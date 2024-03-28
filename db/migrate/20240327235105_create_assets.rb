class CreateAssets < ActiveRecord::Migration[7.1]
  def change
    create_table :assets do |asset|
      asset.string :name
      asset.string :title
      asset.string :description
      asset.string :year
      asset.string :genre
      asset.string :notes
      asset.string :playback_id
    end
  end
end
