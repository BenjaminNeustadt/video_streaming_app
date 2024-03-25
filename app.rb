require 'sinatra'
require 'sinatra/reloader' if development?
require 'mux_ruby'
require 'net/http'
require 'uri'
require 'dotenv/load'

require 'pp'

class Application < Sinatra::Base

  configure :developmment do
    register Sinatra::Reloader
  end

  openapi = MuxRuby.configure do |config|
    config.username = ENV.fetch('MUX_TOKEN_ID', nil)
    config.password = ENV.fetch('MUX_TOKEN_SECRET', nil)
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
    assets = assets_api.list_assets

    # puts assets.data
    # puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
    # puts assets.data.count
    # puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"

    @assets = assets.data
    erb :index
  end

  get '/admin' do
    erb :admin
  end

  # def upload_file(file_path, url)
  #   uri = URI(url)
  #   file_data = File.binread(file_path)

  #   request = Net::HTTP::Put.new(uri)
  #   request.body = file_data

  #   response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
  #     http.request(request)
  #   end

  #   if response.is_a?(Net::HTTPSuccess)
  #     p "File uploaded successfully!"
  #   else
  #     p "Failed to upload file: #{response.code} - #{response.message}"
  #   end
  # end

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
    create_upload_request.cors_origin = 'http://localhost:9292/admin'

    upload = uploads_api.create_direct_upload(create_upload_request)
    upload_id = upload.data.id

    # playback_id_thread = Thread.new do
    puts "This is the upload_id: #{upload_id}"
    get_the_playback_id_of_last_asset(upload_id)
    # end

    upload.data.url
  end

  def metadata_for_last_asset
    assets_api = MuxRuby::AssetsApi.new
    playback_ids_api = MuxRuby::PlaybackIDApi.new
    assets = assets_api.list_assets
    p 'The last data from assets is:'
    p assets.data.first
    # puts "These are the methods on assets_api %s" % assets_api.methods
    # puts "These are the methods on an asset %s" % assets.data.last.methods
    last_asset = assets.data.last
    playback_id_for_latest_asset = assets.data.first.playback_ids.first.id
    methods_on_mux_class = assets.data.first.class.methods.sort
    # playback_id_for_latest_asset = assets.data.first['data']['playback_ids'].first['id']
    p '=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+'
    p 'This is the playback id for the latest asset:'
    p playback_id_for_latest_asset
    p '=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+'
    p 'These are the methods'
    p methods_on_mux_class
  end

  post '/metadata_for_last_asset' do
    metadata_for_last_asset
    erb :admin
  end

  def get_the_playback_id_of_last_asset(asset_id)
    p 'preparing to get the playback id of this last asset'
    # mux_url = "https://api.mux.com/video/v1/uploads/#{upload_id}"
    mux_url_assets = "https://api.mux.com/video/v1/assets/#{asset_id}"

    uri = URI.parse(mux_url_assets)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri)
    request['Content-Type'] = 'application/json'
    request.basic_auth(ENV.fetch('MUX_TOKEN_ID', nil), ENV.fetch('MUX_TOKEN_SECRET', nil))

    # Send the request and handle the response
    p 'Sending request and handing the response…'
    response = http.request(request)

    p 'Response code is: %i' % response.code
    # Return the response body or an error message
    if response.code == '200'
      content_type :json
      p response.body
    else
      p "Failed to fetch upload metadata: #{response.code} #{response.message}"
    end
  end

end
