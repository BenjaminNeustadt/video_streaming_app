require 'dotenv/load'

require 'aws-sdk-s3'
require 'colorize'
require 'httparty'
require 'json'
require 'net/http'
require 'mux_ruby'
require 'puma'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require 'sinatra/partial'
require 'uri'

require './models/asset.rb'
require './models/user.rb'

require './helpers/monitoring_helpers.rb'
require './helpers/mux_helpers.rb'
require './helpers/asset_entry_helpers.rb'
require './helpers/aws_helpers.rb'
require './helpers/user_helpers.rb'
require './helpers/environment_helpers.rb'

require 'sinatra/flash'


class Application < Sinatra::Base
  include AWSHelpers
  include AssetEntryHelpers
  include EnvironmentHelpers
  include MonitoringHelpers
  include MuxHelpers
  include UserHelpers

  before do
    session[:start_time] ||= Time.now
    # @ip_address = settings.development_ip_address || settings.production_ip_address 
    # @ip_address          = request.ip
    @ip_address        = "82.33.149.50"
    @api_key             = ENV['VPNAPI_ACCESS_KEY']
    @admin_password      = ENV['ADMIN_PASSWORD']
    url_format           = ENV['API_FOR_GETTING_DATA']
    @url                 = url_format % { ip_address: @ip_address, api_key: @api_key }
    response             = HTTParty.get(@url)
    @ip_data             = JSON.parse(response.body)

    # @ip_present_security = @ip_data["security"]
    # @client_proxy_status = @ip_data["security"]["proxy"]
    # @ip_geolocation      = @ip_data["location"]

    # @client_isp          = @ip_data['network']["autonomous_system_organization"]

    # @client_city         = @ip_data["location"]["city"]
    # @client_country      = @ip_data["location"]["country"]
    # @client_region       = @ip_data["location"]["region"]
    # @client_latitude     = @ip_data["location"]["latitude"]
    # @client_longitude    = @ip_data["location"]["longitude"]
    # @client_location     = @ip_geolocation["city"]

    # @ip_network          = @ip_data["network"]
    # @client_network      = @ip_network["network"]

    @language_options = LANGUAGE_CODES
  end

  configure :development do
    MESSAGES[:sucessful_dev_config].call
    set :development_ip_address, ENV['TEST_IP_ADDRESS']
    register Sinatra::Reloader
  end

  configure :production do
    MESSAGES[:sucessful_prod_config].call
  end

  configure do
    ENV_NOTICE.call(settings)
    set :server, 'puma'
    set :session_secret, SecureRandom.hex(64)
    register Sinatra::ActiveRecordExtension
    register Sinatra::Flash
  end

  configure do
    @aws_s3_access_key = ENV['S3_ACCESS_KEY']
    @aws_s3_secret_key = ENV['S3_SECRET_KEY']

    register Sinatra::ActiveRecordExtension
    set :method_override, true
    register Sinatra::Partial

    enable :sessions
    enable :partial_underscores
    set :bind, '0.0.0.0'
    set :port, 8080
    set :partial_template_engine, :erb

    # load_aws_configurations
    Aws.config.update({
      region: 'eu-north-1',
      credentials: Aws::Credentials.new(@aws_s3_access_key, @aws_s3_secret_key)
      })
    set :s3, Aws::S3::Resource.new
    # TODO: CHANGE BUCKET
    set :bucket, settings.s3.bucket('folio-test-bucket')
  end

  SESSION_EXPIRATION_TIME = 30 * 60

  MuxRuby.configure do |config|
    config.username = ENV.fetch('MUX_TOKEN_ID')
    config.password = ENV.fetch('MUX_TOKEN_SECRET')
  end

  assets_api = MuxRuby::AssetsApi.new
  assets     = assets_api.list_assets

#### =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ ####
####   ASSET HELPERS                  ####
#### =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ ####

def convert_to_minutes(seconds)
  (seconds / 60).round
end

#### =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ ####
####   ADMIN HELPERS                  ####
#### =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ ####

  def update_current_user_time_on_site(session_id, time)
    users = User.all
    user = users.find_by(session_id: session_id)
    if user
      user.update(time_on_site: user.time_on_site.to_i + time)
    end
  end

  def find_user_for_that_session_id(session_id)
    user = User.all
    @current_user = user.find_by(session_id: session_id)
  end

# =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
# *******    ROUTE HELPERS       *********
# =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

  def admin_logged_in?
    session[:admin] == true
  end

  def valid_visit
    session[:logged_in] | session[:admin]
  end


# =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
# *******    USER LOGIN          *********
# =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

  get '/login' do
    # TODO: figure out how we can have this one place only
    # @ip_address          = request.ip
    # @ip_address          = "82.33.149.50"
    @api_key             = ENV['VPNAPI_ACCESS_KEY']
    @admin_password      = ENV['ADMIN_PASSWORD']
    url_format           = ENV['API_FOR_GETTING_DATA']
    @url                 = url_format % { ip_address: @ip_address, api_key: @api_key }
    response             = HTTParty.get(@url)
    p "# =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
    p "THIS IS THE DATA TO INSPECT"
    p response
    p JSON.parse(response.body)["ip"]
    p "THIS IS THE DATA TO INSPECT"
    p "# =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
    @ip_data             = JSON.parse(response.body)
    @api_key             = ENV['VPNAPI_ACCESS_KEY']

    @admin_password      = ENV['ADMIN_PASSWORD']
    url_format           = ENV['API_FOR_GETTING_DATA']

    @ip_present_security = @ip_data["security"]

    # p"=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+" 
    # p @ip_present_security
    # p"=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+" 

    @client_vpn_presence = @ip_data["security"]["vpn"]
    @client_proxy_status = @ip_data["security"]["proxy"]
    @ip_geolocation      = @ip_data["location"]

    @client_isp          = @ip_data['network']["autonomous_system_organization"]
    @client_city         = @ip_data["location"]["city"]
    @client_country      = @ip_data["location"]["country"]
    @client_region       = @ip_data["location"]["region"]
    @client_location     = @ip_geolocation["city"]
    @ip_network          = @ip_data["network"]
    @client_network      = @ip_network["network"]
    @client_latitude     = @ip_data["location"]["latitude"]
    @client_longitude    = @ip_data["location"]["longitude"]

    @sesh = session[:session_id]

    @current_user = User.create(
      ip_address: @ip_address,
      ip_city_location: @client_city,
      ip_country_location: @client_country,
      ip_region_location: @client_region,
      ip_vpn_status: @client_vpn_presence,
      ip_proxy_status: @client_proxy_status,
      session_id: @sesh,
      isp: @client_isp,
      latitude: @client_latitude,
      longitude: @client_longitude,
      time_on_site: ''
    )
    # time_on_site = Time.now - session[:start_time]
    erb :login, layout: false
  end

  post '/login' do
    request_body = JSON.parse(request.body.read)
    password = request_body['password']

    if password == ENV['USER_PASSWORD']
      session[:logged_in] = true
      find_user_for_that_session_id(session[:session_id].to_s)
      @current_user.update(has_validated: true)
      @sesh = session[:session_id]
      { success: true }.to_json
    else
      flash[:error] = "Wrong password: check spelling or contact admin..."
      { success: false }.to_json
    end
  end

# =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
# *******    ADMIN LOGIN         *********
# =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

  get '/admin_login' do
    erb :admin_login, layout: false
  end

  post '/admin_login' do
    password = params[:password]
    if password == ENV.fetch('ADMIN_PASSWORD')
      session[:admin] = true
      redirect '/admin'
    else
      flash[:message] = "wrong password..."
      redirect '/admin_login'
    end
  end

  get '/logout' do
    session[:admin] = false
    redirect '/'
  end

# =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
# *******    SITE VISIT         *********
# =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

  get '/' do
    redirect '/login' unless valid_visit

    @sesh = session[:session_id]
    session[:start_time] = Time.now
    @country_options  = COUNTRY_OPTIONS
    @genre_options    = GENRE_OPTIONS

    @assets           = Asset.all
    dark_mode_enabled = request.cookies['darkModeEnabled'] == 'true'
    erb :index, locals: { dark_mode_enabled: dark_mode_enabled }
  end

  post '/log_time_on_site' do
    @time_on_site = params['timeOnSite'].to_i
    @inspection   = params.inspect
    @sesh         = params["sessionID"]
    find_user_for_that_session_id(@sesh)
    update_current_user_time_on_site(@sesh, @time_on_site)

    # Perhaps will need to update the current_user's time on site on the object itself
    begin
      File.open('time_on_site.log', 'a') do |file|
        file.puts "User IP: #{@current_user.ip_address} - Time on site: #{@time_on_site} seconds - Date : #{Time.now}"
      end
    rescue StandardError => e
      puts "Error creating or appending to time_on_site.log: #{e.message}"
    end
  end

  get '/selection' do
    redirect '/login' unless valid_visit
    @genre_options    = GENRE_OPTIONS
    @assets = Asset.where(top_picks: true).to_a
    # @language_options = LANGUAGE_CODES
    @filter = "Top Picks"
    erb :filtered_assets
  end

  get '/genre/:genre' do
    redirect '/login' unless valid_visit
    @genre_options    = GENRE_OPTIONS
    genre             = params[:genre]
    @assets           = Asset.where('genre LIKE ?', "%#{genre}%")
    @filter           = genre
    erb :filtered_assets
  end

  get '/director/:director' do
    redirect '/login' unless valid_visit
    @genre_options    = GENRE_OPTIONS
    director          = params[:director]
    @assets           = Asset.where('directors LIKE ?', "%#{director}%")
    @filter           = director
    erb :filtered_assets
  end

  get '/country/:country' do
    redirect '/login' unless valid_visit
    @genre_options    = GENRE_OPTIONS
    country           = params[:country]
    @assets           = Asset.where('country LIKE ?', "%#{country}%")
    @filter           = country
    erb :filtered_assets
  end

#### =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ ####
####   ADMIN ROUTES                   ####
#### =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ ####

  get '/admin' do
    redirect '/admin_login' unless admin_logged_in?
    # p 'WE ARE IN THE ADMIN PANEL'
    @users            = User.all
    @ip_data          = @user_ip.to_s
    @country_options  = COUNTRY_OPTIONS
    @genre_options    = GENRE_OPTIONS

    # This is the endpoint for retrieving metrics data
    url          = URI('https://api.mux.com/data/v1/metrics/comparison')
    request      = Net::HTTP::Get.new(url.to_s)
    request.basic_auth("#{@mux_token_id}", "#{@mux_secret_id}")
    request.content_type = 'application/json'

    http         = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    response     = http.request(request)

    if response.code == '200'
      data = JSON.parse(response.body)
      @watch_time         = data['data'].first['watch_time']
      @view_count         = data['data'].first['view_count']
      @started_views      = data['data'].first['started_views']
      @ended_views        = data['data'].first['ended_views']
      @unique_viewers     = data['data'].first['unique_viewers']
      @total_playing_time = data['data'].first['total_playing_time']
    else
      body response.body
    end

    @sum_db_assets  = amount_database_assets
    @sum_mux_assets = amount_of_mux_assets
    erb :admin
  end

  # TODO: This is a logging button
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
    update_subtitle_track_info_for(asset_id)
    redirect '/'
  end

  def time_to_seconds(hour=0, minute=0, second=0)
    String(hour * 3600 + minute * 60 + second)
  end

  post '/upload_asset_metadata' do
    title               = params[:title]
    director            = params[:director]
    description         = params[:description]
    year                = params[:year]
    countries           = params[:countries]
    top_pick            = params[:top_picks].present?
    genre               = params[:genre]
    notes               = params[:notes]
    # Thumbnail_time values
    hour                = params[:hour].to_i
    minute              = params[:minute].to_i
    second              = params[:second].to_i
    # Subtitiles
    subtitle_name       = params[:subtitle_name]
    language_code       = params[:language_code]
    file_given          = params.dig(:subtitle_track, :tempfile)

    if file_given
      subtitle_track_file = params[:subtitle_track][:tempfile]
      track_filename      = params[:subtitle_track][:filename]

      upload_to_aws_s3_storage(subtitle_track_file, track_filename)

      asset_id = asset_id_for_latest_asset
      assets_api = MuxRuby::AssetsApi.new
      assets_api.create_asset_track(asset_id, create_track_request_for_subtitle(@subtitle_track_url, language_code, subtitle_name))
    end

    subtitle_track_info_for_last_upload

    Asset.create(
      title: title,
      directors: director,
      description: description,
      year: year,
      genre: genre,
      duration: duration_for_last_asset_uploaded,
      country: countries,
      notes: notes,
      top_picks: top_pick,
      thumbnail_time: time_to_seconds(hour, minute, second),
      playback_id: playback_id_for_latest_asset,
      asset_id: asset_id_for_latest_asset,
      subtitle_language_codes: @subtitle_language_codes,
      subtitle_names: @subtitle_names
    )
    # p "Successfully added metadata to uploaded asset"
    redirect '/admin'
  end

#### =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ ####
####   Route for updating an asset    ####
#### =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ ####

  put '/update_asset_metadata/:id' do
    # Thumbnail_time values
    hour                = params[:hour]
    minute              = params[:minute]
    second              = params[:second]

    p "========================================SMILES"
    p params[:top_pick]
    p "========================================SMILES"

    # convert them to integer for operations
    time = hour.to_i, minute.to_i, second.to_i

    @asset = Asset.find_by(asset_id: params[:id])
    @asset.update(
      title: params[:title],
      directors: params[:director],
      description: params[:description],
      year: params[:year],
      country: params[:country],
      genre: params[:genre],
      top_picks: params[:top_pick].present?,
      notes: params[:notes],
      thumbnail_time: time_to_seconds(*time)
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
    # p "ASSET DELETED"
    begin
      mux_assets_api.get_asset(asset_id)
      # :TODO: Remove logging
      # p 'Asset still exists after deletion. Error!'
      exit 255
    rescue MuxRuby::NotFoundError => e
      # :TODO: Remove logging
      # p 'Asset deleted successfully!'
    end
    # :TODO: Remove logging
    # puts "delete-asset OK"
    redirect '/'
  end


end
