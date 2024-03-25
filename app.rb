require 'sinatra'
require "sinatra/reloader" if development?
require 'mux_ruby'
require 'net/http'
require 'uri'
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
  # puts "Listing Assets in account:\n\n"

  # assets = assets_api.list_assets()
  # assets.data.each do | asset |
  #   puts "Asset ID: #{asset.id}"
  #   puts "Status: #{asset.status}"
  #   puts "Duration: #{asset.duration.to_s}\n\n"
  #   puts "Playback ID: #{asset.playback_ids.first.id}\n\n"
  # end
  # puts "assets data type: #{assets.data.class}\n"
  # puts "Number of assets read: #{assets.data.count}\n"

  enable :sessions
  set :bind, '0.0.0.0'
  set :port, 8080

  get '/' do
    assets_api = MuxRuby::AssetsApi.new
    assets = assets_api.list_assets()

    # puts assets.data
    # puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
    # puts assets.data.count
    # puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"

    @assets = assets.data
    erb :index
  end

  get '/admin' do
    erb :admin, locals: { special_endpoint: nil}
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
        upload_id = upload.data.id

        # playback_id_thread = Thread.new do
        puts "This is the upload_id: #{upload_id}"
        get_the_playback_id_of_last_asset(upload_id)
        # end

        endpoint= upload.data.url
        endpoint
  end

  post '/get_special_endpoint' do
    special_endpoint = special_endpoint()
    erb :admin, locals: { special_endpoint: special_endpoint }
  end

  def get_the_playback_id_of_last_asset(upload_id)
      mux_url = "https://api.mux.com/video/v1/uploads/#{upload_id}"

      uri = URI.parse(mux_url) 
      http = Net::HTTP.new(uri.host, uri.port)
      # http.use_ssl = true 
    
    
      request = Net::HTTP::Get.new(uri)
      request['Content-Type'] = 'application/json'
      request.basic_auth(ENV['MUX_TOKEN_ID'], ENV['MUX_TOKEN_SECRET'])
    
      # Send the request and handle the response
      response = http.request(request)
    
      # Return the response body or an error message
      if response.code == '200'
        content_type :json
        response.body
      else
        "Failed to fetch upload metadata: #{response.code} #{response.message}"
      end
  end

end
