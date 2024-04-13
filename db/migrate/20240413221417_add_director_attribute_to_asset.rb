class AddDirectorAttributeToAsset < ActiveRecord::Migration[7.1]
  def change
    add_column :assets, :directors, :string
  end
end
