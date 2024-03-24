
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

