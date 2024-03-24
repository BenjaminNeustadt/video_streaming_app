require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/activerecord'
require 'mux_ruby'

require 'net/http'
require 'dotenv'
require 'solid_assert'
Dotenv.load

# Load environment variables from .env file
# Database configuration
# configure :development do
#     set :database, { adapter: 'sqlite3', database: ':memory:' }
# end
#
# # Set session timeout to 15 minutes
# set :session_expire_after, 900
#
# # Database configuration
# set :database_file, 'config/database.yml'
#
# # Models
# class Film < ActiveRecord::Base
#   has_and_belongs_to_many :tags
# end
#
# class Tag < ActiveRecord::Base
#   has_and_belongs_to_many :films
# end

# Routes

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

  
  def playback_id(something)
    something.playback_ids.first.id
  end

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

      uploads_api = MuxRuby::DirectUploadsApi.new

      # ========== create-direct-upload ==========
      create_asset_request = MuxRuby::CreateAssetRequest.new
      create_asset_request.playback_policy = [MuxRuby::PlaybackPolicy::PUBLIC]
      create_upload_request = MuxRuby::CreateUploadRequest.new
      create_upload_request.new_asset_settings = create_asset_request
      create_upload_request.timeout = 3600
      create_upload_request.cors_origin = "philcluff.co.uk"
      upload = uploads_api.create_direct_upload(create_upload_request)



      puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+\n\n"
      puts "This is the value of upload: #{upload}\n\n"
      puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+\n\n"

      puts "==============================\n\n"
      puts "This is the signed url for uploading: #{upload.data.url}\n\n"
      puts "==============================\n\n"

      assert upload != nil
      assert upload.data != nil
      assert upload.data.id != nil
      puts "create-direct-upload OK ✅"

      erb :admin
    end

    post '/upload_new_asset' do
      input_new_video = params[:new_video]
      file_name_for_new_video = params[:new_video][:filename]
      puts input_new_video

      # API Client Initialization
      assets_api = MuxRuby::AssetsApi.new
      playback_ids_api = MuxRuby::PlaybackIDApi.new

      uploads_api = MuxRuby::DirectUploadsApi.new

      # ========== create-direct-upload ==========
      create_asset_request = MuxRuby::CreateAssetRequest.new
      create_asset_request.playback_policy = [MuxRuby::PlaybackPolicy::PUBLIC]

      create_upload_request = MuxRuby::CreateUploadRequest.new

      create_upload_request.new_asset_settings = create_asset_request
      create_upload_request.timeout = 3600
      create_upload_request.cors_origin = "philcluff.co.uk"

      upload = uploads_api.create_direct_upload(create_upload_request)

      signed_upload_url = upload.data.url
      endpoint = signed_upload_url + '/' + file_name_for_new_video

      # We will use:

      # ========== create-asset ==========
      # car = MuxRuby::CreateAssetRequest.new
      # car.input = [{:url => 'https://storage.googleapis.com/muxdemofiles/mux-video-intro.mp4'}, {:url => "https://tears-of-steel-subtitles.s3.amazonaws.com/tears-fr.vtt", :type => "text", :text_type => "subtitles", :name => "French", :language_code => "fr", :closed_captions => false}]

      create_asset_request.input = [{:url => endpoint}]
      create_response = assets_api.create_asset(create_asset_request)

      assert create_response != nil
      assert create_response.data.id != nil
      puts "create-asset OK ✅"
    end

  # run! if app_file == $0
end

#=+=+=+=+=+=+=+=+=+=+=+=+=+=+==+=+=+=+=+=+=+=+=+=+=+=+=+=+=++
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+==+=+=+=+=+=+=+=+=+=+=+=+=+=+=++
# # Prepare the request body
#       request_body = {
#         cors_origin: '*',
#         new_asset_settings: {
#           playback_policy: ['public'],
#           encoding_tier: 'baseline'
#         }
#       }.to_json
# 
#       # Prepare the request URI
#       uri = URI('https://api.mux.com/video/v1/uploads')
# 
#       # Create a new HTTP request
#       request = Net::HTTP::Post.new(uri)
#       request.body = request_body
#       request['Content-Type'] = 'application/json'
#       request.basic_auth(ENV['MUX_TOKEN_ID'], ENV['MUX_TOKEN_SECRET'])
# 
#       # Send the HTTP request
#       response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
#         http.request(request)
#       end
# 
#       # Parse the response
#       if response.is_a?(Net::HTTPSuccess)
#         # Extract the signed upload URL from the JSON response
#         response_body = JSON.parse(response.body)
#         @signed_upload_url = response_body['data']['url']
# 
#         # Render the admin page with the signed upload URL
#         erb :admin
#       else
#         # Handle error case (e.g., log error)
#         status response.code
#         "Failed to fetch signed upload URL"
#       end
# post '/login' do
#   if params[:password] == ENV['SITE_PASSWORD']
#     session[:authenticated] = true
#     session[:last_activity_time] = Time.now
#     redirect '/'
#   else
#     erb :login
#   end
# end


# post 'films' do
#   redirect '/login' unless admin?
#   @film = Film.create(title:params[:title], description: params[:description])
#   tags = params[:tags].split(',').map(&:strip)
#   tags.each do |tag_name|
#     tag = Tag.find_or_create_by(name: tag_name)
#     @film.tags << tag
#   end
#   # Code for Mux upload could be added here
#   redirect '/'
# end

#helpers do
#   def authenticated?
#     session[:authenticated] && !session_expired?
#   end
#
#   def session_expired?
#     return false unless session[:last_activity_time]
#     Time.now = session[:last_activity_time] >= settings.session_expire_after
#   end
#
#   def admin?
#     session[:authenticated] && session[:admin]
#   end
# end

# use Rack::Session::Cookie, expire_after: settings.session_expire_after
