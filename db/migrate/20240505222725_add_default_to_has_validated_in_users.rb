class AddDefaultToHasValidatedInUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :has_validated, :boolean, default: false
  end
end
