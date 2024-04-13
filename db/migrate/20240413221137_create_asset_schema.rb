class CreateAssetSchema < ActiveRecord::Migration[7.1]
  def change
    create_table "assets", force: :cascade do |t|
      t.string "name"
      t.string "title"
      t.string "description"
      t.string "year"
      t.string "genre"
      t.string "notes"
      t.string "playback_id"
      t.string "asset_id"
      t.string "thumbnail_time"
    end
  end
end
