require 'sinatra'
require 'sinatra/reloader' if development?
require 'mux_ruby'
require 'net/http'
require 'uri'
require 'json'
require 'dotenv/load'
require 'sinatra/activerecord'

require './helpers/monitoring_helper.rb'
require './helpers/mux_helpers.rb'
require './models/asset.rb'

class Application < Sinatra::Base
  include MonitoringHelpers
  include MuxHelpers

  configure do
    register Sinatra::ActiveRecordExtension
    set :method_override, true
    set :database, {adapter: "sqlite3", database: "db/test_pirate_hub.sqlite3"}
  end

  before do
    @user_ip = request.ip
  end

  configure :developmment do
    register Sinatra::Reloader
  end

  MuxRuby.configure do |config|
    config.username = ENV.fetch('MUX_TOKEN_ID', nil)
    config.password = ENV.fetch('MUX_TOKEN_SECRET', nil)
  end

  assets_api = MuxRuby::AssetsApi.new
  assets = assets_api.list_assets

  enable :sessions
  set :bind, '0.0.0.0'
  set :port, 8080

  before do
    @user_ip = request.ip
  end

  get '/' do
    p "The assets in the database are:"
    p Asset.all
    @assets = Asset.all
    p "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
    p "The assets in the MUX are:"
    p assets_raw_data
    erb :index
  end

  get '/admin' do
    p "WE ARE IN THE ADMIN PANEL"
    @ip_data = "The IP address we found for your account is: #{@user_ip}"

    url = URI('https://api.mux.com/data/v1/metrics/comparison')

    mux_token_id = ENV.fetch('MUX_TOKEN_ID')
    mux_secret_id = ENV.fetch('MUX_TOKEN_SECRET')

    request = Net::HTTP::Get.new(url.to_s)
    request.basic_auth("#{mux_token_id}","#{mux_secret_id}")
    request.content_type = 'application/json'

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    response = http.request(request)

    if response.code == '200'
      data = JSON.parse(response.body)
      p data["data"].first
      @watch_time = data["data"].first["watch_time"]
      @view_count = data["data"].first["view_count"]
      @started_views = data["data"].first["started_views"]
      @ended_views = data["data"].first["ended_views"]
      @unique_viewers = data["data"].first["unique_viewers"]
      @total_playing_time = data["data"].first["total_playing_time"]
    else
      p status response.code.to_i
      body response.body
    end

    @sum_db_assets = amount_database_assets
    @sum_mux_assets = amount_of_mux_assets
    erb :admin
  end

  post '/metadata_for_last_asset' do
    p playback_id_for_latest_asset
    p asset_id_for_latest_asset
    erb :admin
  end

  post '/assets/:asset_id/add_subtitle_track' do
    asset_id = params[:asset_id]
    # subtitle_track_file = params[:subtitle_track]
  
    # subtitle_track_content = File.binread(subtitle_track_file[:tempfile].path)
  
    url = "https://folio-test-bucket.s3.eu-north-1.amazonaws.com/Delicatessen.1991.1080p.BluRay.x264.anoXmous_eng.srt"

    create_track_request = MuxRuby::CreateTrackRequest.new(
      url: url,
      type: 'text',
      text_type: 'subtitles',
      language_code: 'en', 
      name: 'Subs test in folio', 
      closed_captions: false
    )
  
    assets_api = MuxRuby::AssetsApi.new
    create_track_response = assets_api.create_asset_track(asset_id, create_track_request)

    redirect '/'
  
  end
  

  post '/upload_asset_metadata' do
    title = params[:title]
    description = params[:description]
    year = params[:year]
    country = params[:country]
    genre = params[:genre]
    notes = params[:notes]

    asset = Asset.create(
      title: title,
      description: description,
      year: year,
      genre: genre,
      notes: notes,
      playback_id: playback_id_for_latest_asset,
      asset_id: asset_id_for_latest_asset
    )
    p "Successfully added metadata to uploaded asset..."
    p asset
    redirect '/admin'
  end

# Route for updating an asset

  put '/update_asset_metadata/:id' do

    @asset = Asset.find_by(asset_id: params[:id])
    @asset.update(
      title: params[:title],
      description: params[:description],
      year: params[:year],
      notes: params[:notes]
    )
    redirect '/'
  end

  delete '/assets/:id' do
    asset_id = params[:id]
    mux_assets_api = MuxRuby::AssetsApi.new
    mux_assets_api.delete_asset(asset_id)
    status 204 # No content
    asset_to_remove = Asset.find_by(asset_id: asset_id)
    asset_to_remove.destroy
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


