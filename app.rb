require 'sinatra'
require 'sinatra/reloader' if development?
require 'mux_ruby'
require 'net/http'
require 'uri'
require 'dotenv/load'
require 'sinatra/activerecord'


class Application < Sinatra::Base

  configure do
    register Sinatra::ActiveRecordExtension
    set :method_override, true
    set :database, {adapter: "sqlite3", database: "db/test_pirate_hub.sqlite3"}
  end

  configure :developmment do
    register Sinatra::Reloader
  end

  MuxRuby.configure do |config|
    config.username = ENV.fetch('MUX_TOKEN_ID', nil)
    config.password = ENV.fetch('MUX_TOKEN_SECRET', nil)
  end

  # This should be used for monitoring instead
  assets_api = MuxRuby::AssetsApi.new
  assets = assets_api.list_assets

  enable :sessions
  set :bind, '0.0.0.0'
  set :port, 8080

  get '/' do
    p "The assets are:"
    # @assets = Asset.all
    # p "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
    @assets = assets.data
    # "testing in progress"
    erb :index
  end

  get '/admin' do
    p "WE ARE IN THE ADMIN PANEL"
    erb :admin
  end

  def debugger_logger
    print Time.now, ': '
    puts "These are the current assets in the Mux:"
    p assets
    puts "These are the current number of assets:"
    p assets.count
  end

  def special_endpoint
    mux_uploader_api = MuxRuby::DirectUploadsApi.new
    create_asset_request = MuxRuby::CreateAssetRequest.new
    create_asset_request.playback_policy = [MuxRuby::PlaybackPolicy::PUBLIC]

    create_upload_request = MuxRuby::CreateUploadRequest.new
    create_upload_request.new_asset_settings = create_asset_request
    create_upload_request.timeout = 3600
    create_upload_request.cors_origin = 'http://localhost:9292/admin'

    uploaded_video = mux_uploader_api.create_direct_upload(create_upload_request)
    uploaded_asset_id = uploaded_video.data.id
    puts "This is the upload_id: #{uploaded_asset_id}"
    playback_id_for_latest_asset
    uploaded_video.data.url
  end

  def playback_id_for_latest_asset
    assets_api = MuxRuby::AssetsApi.new
    assets = assets_api.list_assets
    if assets && assets.data && !assets.data.empty?
      p 'The last data from assets is:'
      p assets.data.first
      p 'The playback_id for the last asset is:'
      p assets.data.first.playback_ids.first.id
    else
      "Nothing here yet"
    end
  end

  def asset_id_for_latest_asset
    assets_api = MuxRuby::AssetsApi.new
    assets = assets_api.list_assets
    if assets && assets.data && !assets.data.empty?
      assets = assets_api.list_assets
      p 'The asset id for the last assets is:'
      assets.data.first.id
    end
  end


  post '/metadata_for_last_asset' do
    p playback_id_for_latest_asset
    p asset_id_for_latest_asset
    erb :admin
  end

  post '/upload_asset_metadata' do

# :TODO: this is where we create a Pirate asset with the metadata as attributes on the object created
# and sent to the database
    p title = params[:title]
    p description = params[:description]
    p year = params[:year]
    p country = params[:country]
    p genre = params[:genre]
    p notes = params[:notes]
    pirate_asset = Asset.create(
      title: title,
      description: description,
      year: year,
      genre: genre,
      notes: notes,
      playback_id: playback_id_for_latest_asset,
      id: asset_id_for_latest_asset  
    )
    p pirate_asset
    all_assets = Asset.all
    p all_assets
    redirect '/admin'
  end

  delete '/assets/:id' do
    asset_id = params[:id]
    mux_assets_api = MuxRuby::AssetsApi.new
    mux_assets_api.delete_asset(asset_id)
    status 204 # No content
    p "ASSET DELETED"
    begin
      mux_assets_api.get_asset(asset_id)
      p 'Asset still exists after deletion. Error!'
      exit 255
    rescue MuxRuby::NotFoundError => e
      p 'Asset deleted successfully!'
    end
    puts "delete-asset OK ✅"
    redirect '/'
  end

end

class Asset < ActiveRecord::Base
  # has_a :title
  # has_a :description
  # has_a :playback_id
  # has_a :duration
  # has_many :tags
end

