class AddAssetIdToAssets < ActiveRecord::Migration[7.1]
  def change
    add_column :assets, :asset_id, :string
  end
end
