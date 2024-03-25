require 'sinatra'
require 'sinatra/reloader' if development?
require 'mux_ruby'
require 'net/http'
require 'uri'
require 'dotenv/load'
require 'sinatra/activerecord'

class Application < Sinatra::Base

  private

  def initialize
    assets_api = MuxRuby::AssetsApi.new
    self.assets = assets_api.list_assets
  end

  def debugger_logger
    print Time.now, ': '
    puts "These are the current assets in the Mux:"
    p assets
    puts "These are the current number of assets:"
    p assets.count
  end

  public

  attr_reader :assets
  attr_writer :assets

  configure :developmment do
    register Sinatra::Reloader
  end

  MuxRuby.configure do |config|
    config.username = ENV.fetch('MUX_TOKEN_ID', nil)
    config.password = ENV.fetch('MUX_TOKEN_SECRET', nil)
  end

  enable :sessions
  set :bind, '0.0.0.0'
  set :port, 8080

  get '/' do
    erb :index
  end

  get '/admin' do
    erb :admin
  end

  def special_endpoint
    # mux_uploader_api = MuxRuby::DirectUploadsApi.new
    create_asset_request = MuxRuby::CreateAssetRequest.new
    create_asset_request.playback_policy = [MuxRuby::PlaybackPolicy::PUBLIC]

    create_upload_request = MuxRuby::CreateUploadRequest.new
    create_upload_request.new_asset_settings = create_asset_request
    create_upload_request.timeout = 3600
    create_upload_request.cors_origin = 'http://localhost:9292/admin'

    uploaded_video = mux_uploader_api.create_direct_upload(create_upload_request)
    uploaded_asset_id = upload.data.id
    puts "This is the upload_id: #{uploaded_asset_id}"
    get_the_playback_id_of_last_asset(uploaded_asset_id)
    uploaded_video.data.url
  end

  def playback_id_for_latest_asset
    assets_api = MuxRuby::AssetsApi.new
    assets = assets_api.list_assets
    p 'The last data from assets is:'
    p assets.data.first
    assets = assets_api.list_assets
    p 'The last data from assets is:'
    p assets.data.first
    assets.data.first.playback_ids.first.id
  end

  post '/metadata_for_last_asset' do
    playback_id_for_latest_asset
    erb :admin
  end

end
