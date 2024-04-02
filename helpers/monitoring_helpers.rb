require 'mux_ruby'

module MonitoringHelpers

  def assets_raw_data
    assets_api = MuxRuby::AssetsApi.new
    assets = assets_api.list_assets
  end

  def amount_of_mux_assets
    assets_api = MuxRuby::AssetsApi.new
    assets = assets_api.list_assets
    assets.data.count
  end

  def amount_database_assets
    Asset.all.count
  end

end

