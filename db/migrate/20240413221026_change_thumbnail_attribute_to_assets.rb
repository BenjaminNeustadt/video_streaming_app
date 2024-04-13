class ChangeThumbnailAttributeToAssets < ActiveRecord::Migration[7.1]
  def change
    remove_column :assets, :thumbnail_position

    add_column :assets, :thumbnail_time, :string
  end
end
