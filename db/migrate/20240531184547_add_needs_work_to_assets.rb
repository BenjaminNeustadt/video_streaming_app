class AddNeedsWorkToAssets < ActiveRecord::Migration[7.1]
  def change
    add_column :assets, :needs_work, :boolean, default: false 
  end
end
