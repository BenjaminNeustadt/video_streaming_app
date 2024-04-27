class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table "users", force: :cascade do |t|
      t.string "ip_address"
      t.string "ip_city_location"
      t.string "ip_country_location"
      t.string "ip_region_location"
      t.string "ip_vpn_status"
      t.string "ip_proxy_status"
      t.string "time_on_site"
      t.string "isp"
      t.string "session_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
