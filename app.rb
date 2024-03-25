require 'sinatra'
require 'sinatra/reloader' if development?
require 'mux_ruby'
require 'net/http'
require 'dotenv/load'

module Decorations

  def half(other)
    other * 1/2r
  end
  DIVIDER = ->(length = 80) { puts '=+' * half(length) }

end

class Application < Sinatra::Base

  include Decorations

  configure :developmment do
    register Sinatra::Reloader
  end

  MuxRuby.configure do |config|
    config.username = ENV.fetch('MUX_TOKEN_ID', nil)
    config.password = ENV.fetch('MUX_TOKEN_SECRET', nil)
  end

  # API Client Init
  assets_api = MuxRuby::AssetsApi.new

  # List Assets
  puts "Listing Assets in account:\n\n"

  assets = assets_api.list_assets
  assets.data.each do |asset|
    data =
      {
                       id: asset.id,
                   status: asset.status,
                 duration: asset.duration,
        first_playback_id: asset.playback_ids.first.id
      }
    puts <<~ASSET_INFO % data
      Asset ID: %<id>s
      Status: %<status>s
      Duration: %<duration>s

      Playback ID: %<first_playback_id>s

    ASSET_INFO
  end

  DIVIDER[50]
  puts "assets data type: #{assets.data.class}\n"
  puts "Number of assets read: #{assets.data.count}\n"
  DIVIDER[50]

  enable :sessions
  set :bind, '0.0.0.0'
  set :port, 8080

  get '/' do
    assets_api = MuxRuby::AssetsApi.new
    assets = assets_api.list_assets

    puts assets.data
    DIVIDER[]
    puts assets.data.count

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
    puts response.is_a?(Net::HTTPSuccess) and 'File uploaded successfully!' or
      'Failed to upload file: %<code>s - %<message>s' %
        {code: response.code, message: response.message}
  end

  def special_endpoint
    # API Client Initialization #
    # assets_api = MuxRuby::AssetsApi.new
    # playback_ids_api = MuxRuby::PlaybackIDApi.new
    uploads_api = MuxRuby::DirectUploadsApi.new
    # ========== create-direct-upload ==========
    create_asset_request = MuxRuby::CreateAssetRequest.new
    create_asset_request.playback_policy = [MuxRuby::PlaybackPolicy::PUBLIC]

    create_upload_request = MuxRuby::CreateUploadRequest.new

    create_upload_request.new_asset_settings = create_asset_request
    create_upload_request.timeout = 3600
    create_upload_request.cors_origin = 'http://localhost:9292/admin'

    upload = uploads_api.create_direct_upload(create_upload_request)

    upload.data.url # This ends up being the endpoint
  end

  # TODO: extract the playback ID and allow input for title, description,
  # tags/genre to be inserted and updated, for the admin to change.

  # ============================================================================
  # This is where the
  #  _ __ ___   ___  ___ ___
  # | '_ ` _ \ / _ \/ __/ __|
  # | | | | | |  __/\__ \__ \
  # |_| |_| |_|\___||___/___/
  #
  #                   begins!
  # ============================================================================
  post '/upload_new_asset' do
    # API Client Initialization #
    assets_api = MuxRuby::AssetsApi.new
    # playback_ids_api = MuxRuby::PlaybackIDApi.new
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
    create_upload_request.cors_origin = 'http://localhost:9292/admin'

    upload = uploads_api.create_direct_upload(create_upload_request)

    endpoint = upload.data.url

    upload_file(file_path, endpoint)
    puts 'create-asset OK ✅'
    @signed_upload_url = '%<endpoint>s/%<filename>s' % {
      endpoint:, filename: uploaded_file[:new_video][:filename]
    }

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
