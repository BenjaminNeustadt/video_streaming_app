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

    @assets = assets.data
    erb :index
  end

  get '/admin' do
    erb :admin
  end

  def upload_file(file_path, url)
    uri = URI(url)
    file_data = File.binread(file_path)
  
    request = Net::HTTP::Put.new(uri)
    request.body = file_data
  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
  
    if response.is_a?(Net::HTTPSuccess)
      puts "File uploaded successfully!"
    else
      puts "Failed to upload file: #{response.code} - #{response.message}"
    end
  end

  def special_endpoint
        # API Client Initialization #
        assets_api = MuxRuby::AssetsApi.new
        puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
        puts assets_api
        puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
        playback_ids_api = MuxRuby::PlaybackIDApi.new
        puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
        puts playback_ids_api
        puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
        uploads_api = MuxRuby::DirectUploadsApi.new
        puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
        puts uploads_api
        puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"

        # ========== create-direct-upload ==========
        create_asset_request = MuxRuby::CreateAssetRequest.new
        puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
        puts create_asset_request
        puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
        create_asset_request.playback_policy = [MuxRuby::PlaybackPolicy::PUBLIC]
  
        create_upload_request = MuxRuby::CreateUploadRequest.new

        create_upload_request.new_asset_settings = create_asset_request
        create_upload_request.timeout = 3600
        create_upload_request.cors_origin = "http://localhost:9292/admin"
  
        upload = uploads_api.create_direct_upload(create_upload_request)
  
        endpoint= upload.data.url
        endpoint
  end


    # So what we need to do:
    # create a post route for submitting title and description
    # that is stored in database
    # Should this be one thing, or two separate elements:
    # if they are two separate elements and one fails, then it could still have a video but not title
    # Lets try it a fe ways...

    # Use this:
    # https://soleetal.com/products/sole-et-al-raws-heavyweight-double-layer-tee-black?currency=GBP&variant=47684840489263&utm_medium=cpc&utm_source=google&utm_campaign=Google+Shopping&stkn=2574fade4b08&tw_source=google&tw_adid=693340036694&tw_campaign=21079978443&gad_source=1&gclid=Cj0KCQjwwYSwBhDcARIsAOyL0fh9zXeFjCSvvVjRMy3k4YbrEUbjSrb8FjvtWg4D3WGmpS5la-SYGgkaAiNwEALw_wcB
    # to get the asset information of the last thing that you uploaded


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

      puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
      puts "The ID we get is this: #{upload.data.id}"
      puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      assets = assets_api.list_assets()
      puts "This could be what we need: #{assets.data}"
      puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
      puts "This is the last upload: #{assets.data.last}"

      puts "*******************************"

      puts "Listing Direct Uploads:\n\n"
      uploads = uploads_api.list_direct_uploads()
      uploads.data.each do | upload |
        puts "Status: #{upload.status}"
        puts "Asset ID: #{upload.asset_id}\n\n"
      end

      puts "This is the first upload: #{assets.data.first}"
      puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
      puts "The data for uploads_api we get is this: #{uploads_api.get_direct_upload(upload.data.id)}"
      puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"

      upload_file(file_path, endpoint)
      # endpoint = signed_upload_url + '/' + file_name_for_new_video


      # create_asset_request.input = file_for_new_video
      # create_response = assets_api.create_asset(create_asset_request)

      puts "create-asset OK ✅"
      # @signed_upload_url = endpoint + '/' + uploaded_file[:new_video][:filename]

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