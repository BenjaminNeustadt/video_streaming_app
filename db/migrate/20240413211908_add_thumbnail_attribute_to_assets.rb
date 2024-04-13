class AddThumbnailAttributeToAssets < ActiveRecord::Migration[7.1]
  def change
    add_column :assets, :thumbnail_position, :integer
  end
end
