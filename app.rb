require 'sinatra'
require "sinatra/reloader" if development?
require 'mux_ruby'
require 'net/http'
require 'dotenv/load'

class Application < Sinatra::Base
  configure :developmment do
    register Sinatra::Reloader
  end

  openapi = MuxRuby.configure do |config|
    config.username = ENV['MUX_TOKEN_ID']
    config.password = ENV['MUX_TOKEN_SECRET']
  end

  # API Client Init
  assets_api = MuxRuby::AssetsApi.new

  # List Assets
  puts "Listing Assets in account:\n\n"

  assets = assets_api.list_assets()
  assets.data.each do | asset |
    puts "Asset ID: #{asset.id}"
    puts "Status: #{asset.status}"
    puts "Duration: #{asset.duration.to_s}\n\n"
    puts "Playback ID: #{asset.playback_ids.first.id}\n\n"
  end
  puts "assets data type: #{assets.data.class}\n"
  puts "Number of assets read: #{assets.data.count}\n"

  enable :sessions
  set :bind, '0.0.0.0'
  set :port, 8080

  
  get '/' do
    assets_api = MuxRuby::AssetsApi.new
    assets = assets_api.list_assets()

    puts assets.data
    puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
    puts assets.data.count
    puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"

    # Pass the assets into the view #
    @assets = assets.data
    erb :index
  end

  get '/admin' do

          erb :admin
    end

    post '/upload_new_asset' do

      # ========== This is where the mess begins ==========
      # API Client Initialization #
      assets_api = MuxRuby::AssetsApi.new
      playback_ids_api = MuxRuby::PlaybackIDApi.new
      uploads_api = MuxRuby::DirectUploadsApi.new

      # Params processing for file #
      input_new_video = params[:new_video]
      file_for_new_video = params[:new_video][:tempfile]
      file_name_for_new_video = params[:new_video][:filename]
      puts input_new_video

      # ========== create-direct-upload ==========
      create_asset_request = MuxRuby::CreateAssetRequest.new
      create_asset_request.playback_policy = [MuxRuby::PlaybackPolicy::PUBLIC]

      create_upload_request = MuxRuby::CreateUploadRequest.new

      create_upload_request.new_asset_settings = create_asset_request
      create_upload_request.timeout = 3600
      create_upload_request.cors_origin = "http://localhost:9292/admin"

      upload = uploads_api.create_direct_upload(create_upload_request)

      signed_upload_url = upload.data.url
      endpoint = signed_upload_url + '/' + file_for_new_video

      create_asset_request.input = [{:url => endpoint}]
      create_response = assets_api.create_asset(create_asset_request)

      puts "create-asset OK ✅"

      # Wait for the asset to become ready...
      if create_response.data.status != 'ready'
        puts "    waiting for asset to become ready..."
        while true do
          # ========== get-asset ==========
          if asset.data.status != 'ready'
            puts "Asset not ready yet, sleeping..."
            sleep(1)
          else
            puts "Asset ready checking input info."
            # ========== get-asset-input-info ==========
            input_info = assets_api.get_asset_input_info(asset.data.id)
            break
          end
        end
      end
      puts "get-asset OK ✅"
      puts "get-asset-input-info OK ✅"
    end

  # run! if app_file == $0
end