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

    # Pass the assets into the view 
    @assets = assets.data
    erb :index
  end

  get '/admin' do
    # We just want to access the form 
    erb :admin
  end

  def upload_file(file_path, url)
    uri = URI(url)
    file_data = File.binread(file_path)
  
    request = Net::HTTP::Put.new(uri)
    request.body = file_data
  
    # Set any additional headers if needed
    # request['HeaderName'] = 'HeaderValue'
  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
  
    # Check the response
    if response.is_a?(Net::HTTPSuccess)
      puts "File uploaded successfully!"
    else
      puts "Failed to upload file: #{response.code} - #{response.message}"
    end
  end

  def special_endpoint
        # API Client Initialization #
        assets_api = MuxRuby::AssetsApi.new
        playback_ids_api = MuxRuby::PlaybackIDApi.new
        uploads_api = MuxRuby::DirectUploadsApi.new
        # ========== create-direct-upload ==========
        create_asset_request = MuxRuby::CreateAssetRequest.new
        create_asset_request.playback_policy = [MuxRuby::PlaybackPolicy::PUBLIC]
  
        create_upload_request = MuxRuby::CreateUploadRequest.new
  
        create_upload_request.new_asset_settings = create_asset_request
        create_upload_request.timeout = 3600
        create_upload_request.cors_origin = "http://localhost:9292/admin"
  
        upload = uploads_api.create_direct_upload(create_upload_request)
  
        endpoint= upload.data.url
        endpoint
  end

# TODO:extract the playback ID and allow input for title, description, tags/genre to be inserted and updated, for the admin to change.

  post '/upload_new_asset' do

      # ===================================================
      # ========== This is where the mess begins ==========
      # ===================================================

      # API Client Initialization #
      assets_api = MuxRuby::AssetsApi.new
      playback_ids_api = MuxRuby::PlaybackIDApi.new
      uploads_api = MuxRuby::DirectUploadsApi.new

      # Params processing for file #
      # input_new_video = params[:new_video]
      # file_for_new_video = params[:new_video][:tempfile].read
      uploaded_file = params[:new_video]
      # puts "This is the filename: #{uploaded_file[:new_video][:filename]}"
      file_path = uploaded_file[:tempfile].path
      # puts input_new_video

      # ========== create-direct-upload ==========
      create_asset_request = MuxRuby::CreateAssetRequest.new
      create_asset_request.playback_policy = [MuxRuby::PlaybackPolicy::PUBLIC]

      create_upload_request = MuxRuby::CreateUploadRequest.new

      create_upload_request.new_asset_settings = create_asset_request
      create_upload_request.timeout = 3600
      create_upload_request.cors_origin = "http://localhost:9292/admin"

      upload = uploads_api.create_direct_upload(create_upload_request)

      endpoint= upload.data.url

      upload_file(file_path, endpoint)
      # endpoint = signed_upload_url + '/' + file_name_for_new_video


      # create_asset_request.input = file_for_new_video
      # create_response = assets_api.create_asset(create_asset_request)

      puts "create-asset OK ✅"
      @signed_upload_url = endpoint + '/' + uploaded_file[:new_video][:filename]

      redirect '/'

    end

end

      # # Wait for the asset to become ready...
      # if create_response.data.status != 'ready'
      #   puts "    waiting for asset to become ready..."
      #   while true do
      #     # ========== get-asset ==========
      #     if asset.data.status != 'ready'
      #       puts "Asset not ready yet, sleeping..."
      #       sleep(1)
      #     else
      #       puts "Asset ready checking input info."
      #       # ========== get-asset-input-info ==========
      #       input_info = assets_api.get_asset_input_info(asset.data.id)
      #       break
      #     end
      #   end
      # end
      # puts "get-asset OK ✅"
      # puts "get-asset-input-info OK ✅"