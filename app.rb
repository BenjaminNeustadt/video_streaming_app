require 'sinatra'
require 'sinatra/reloader' if development?
require 'mux_ruby'
require 'net/http'
require 'uri'
require 'json'
require 'dotenv/load'
require 'sinatra/activerecord'

require './helpers/monitoring_helpers.rb'
require './helpers/mux_helpers.rb'
require './helpers/view_helpers.rb'
require './helpers/aws_helpers.rb'
require './models/asset.rb'

require 'aws-sdk-s3'

class Application < Sinatra::Base
  include MonitoringHelpers
  include MuxHelpers
  include ViewHelpers
  include AWSHelpers

  before do
    @user_ip = request.ip
    @aws_s3_access_key = ENV['S3_ACCESS_KEY']
    @aws_s3_secret_key = ENV['S3_SECRET_KEY']
  end

  configure :developmment, :test do
    register Sinatra::Reloader
  end

  configure do
    register Sinatra::ActiveRecordExtension
    set :method_override, true

    Aws.config.update({
      region: 'eu-north-1',
      credentials: Aws::Credentials.new(@aws_s3_access_key, @aws_s3_secret_key)
      })
      set :s3, Aws::S3::Resource.new
      # TODO: THIS BUCKET WILL HAVE TO CHANGE TO SOMETHING ELSE
      set :bucket, settings.s3.bucket('folio-test-bucket')
  end

  MuxRuby.configure do |config|
    config.username = ENV.fetch('MUX_TOKEN_ID')
    config.password = ENV.fetch('MUX_TOKEN_SECRET')
  end

  assets_api = MuxRuby::AssetsApi.new
  assets = assets_api.list_assets

  enable :sessions
  set :bind, '0.0.0.0'
  set :port, 8080

  get '/' do
    @language_options = LANGUAGE_CODES
    @assets = Asset.all
    erb :index
  end

  get '/admin' do
    p 'WE ARE IN THE ADMIN PANEL'
    @ip_data = @user_ip.to_s
    @language_options = LANGUAGE_CODES

    # This is the endpoint for retrieving metrics data
    url = URI('https://api.mux.com/data/v1/metrics/comparison')

    request = Net::HTTP::Get.new(url.to_s)
    request.basic_auth("#{@mux_token_id}", "#{@mux_secret_id}")
    request.content_type = 'application/json'

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    response = http.request(request)

    if response.code == '200'
      data = JSON.parse(response.body)
      p 'The metrics retrieved from the Mux api are:'
      p data['data'].first
      p '=+' * 70
      @watch_time         = data['data'].first['watch_time']
      @view_count         = data['data'].first['view_count']
      @started_views      = data['data'].first['started_views']
      @ended_views        = data['data'].first['ended_views']
      @unique_viewers     = data['data'].first['unique_viewers']
      @total_playing_time = data['data'].first['total_playing_time']
    else
      p status response.code.to_i
      body response.body
    end

    @sum_db_assets = amount_database_assets
    @sum_mux_assets = amount_of_mux_assets
    erb :admin
  end

  # This is a logging button
  post '/metadata_for_last_asset' do
    playback_id_for_latest_asset
    asset_id_for_latest_asset
    erb :admin
  end

  post '/assets/:asset_id/add_subtitle_track' do

    asset_id            = params[:asset_id]
    subtitle_track_file = params[:subtitle_track][:tempfile]
    subtitle_name       = params[:subtitle_name]
    language_code       = params[:language_code]

    upload_to_aws_s3_storage(subtitle_track_file, params[:subtitle_track][:filename])

    create_track_request = MuxRuby::CreateTrackRequest.new(
      url: @subtitle_track_url,
      type: 'text',
      text_type: 'subtitles',
      language_code: language_code,
      name: subtitle_name,
      closed_captions: false
    )

    assets_api = MuxRuby::AssetsApi.new
    create_track_response = assets_api.create_asset_track(asset_id, create_track_request)

    redirect '/'
  end

  post '/upload_asset_metadata' do
    title               = params[:title]
    description         = params[:description]
    year                = params[:year]
    country             = params[:country]
    genre               = params[:genre]
    notes               = params[:notes]

    subtitle_track_file = params[:subtitle_track][:tempfile]
    subtitle_name       = params[:subtitle_name]
    language_code       = params[:language_code]

    upload_to_aws_s3_storage(subtitle_track_file, params[:subtitle_track][:filename])

    create_track_request = MuxRuby::CreateTrackRequest.new(
      url: @subtitle_track_url,
      type: 'text',
      text_type: 'subtitles',
      language_code: language_code,
      name: subtitle_name,
      closed_captions: false
    )

    asset_id = asset_id_for_latest_asset
    assets_api = MuxRuby::AssetsApi.new
    create_track_response = assets_api.create_asset_track(asset_id, create_track_request)

    asset = Asset.create(
      title: title,
      description: description,
      year: year,
      genre: genre,
      notes: notes,
      playback_id: playback_id_for_latest_asset,
      asset_id: asset_id_for_latest_asset
    )
    # :TODO: Remove logging
    p "Successfully added metadata to uploaded asset"
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
      # :TODO: Remove logging
      p 'Asset still exists after deletion. Error!'
      exit 255
    rescue MuxRuby::NotFoundError => e
      # :TODO: Remove logging
      p 'Asset deleted successfully!'
    end
    # :TODO: Remove logging
    puts "delete-asset OK"
    redirect '/'
  end

end
