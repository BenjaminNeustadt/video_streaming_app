require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv/load'

# Load environment variables from .env file
Dotenv.load

# Set session timeout to 15 minutes
set :session_expire_after, 900

# Database configuration
set :database_file, 'conf/database.yml'

# Models
class Film < ActiveRecord::Base
  has_and_belongs_to_many :tags
end

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :films
end

# Routes
get '/' do
  @films = Film.all
  erb :index
end

post '/login' do
  if params[:password] == ENV['SITE_PASSWORD']
    session[:authenticated] = true
    session[:last_activity_time] = Time.now
    redirect '/'
  else
    erb :login
  end
end

get '/admin' do
  redirect '/login' unless admin?
  erb :admin
end

post 'films' do
  redirect '/login' unless admin?
  @film = Film.create(title:params[:title], description: params[:description])
  tags = params[:tags].split(',').map(&:strip)
  tags.each do |tag_name|
    tag = Tag.find_or_create_by(name: tag_name)
    @film.tags << tag
  end
  # Code for Mux upload could be added here
  redirect '/'
end

helpers do
  def authenticated?
    session[:authenticated] && !session_expired?
  end

  def session_expired?
    return false unless session[:last_activity_time]
    Time.now = session[:last_activity_time] >= settings.session_expire_after
  end

  def admin?
    session[:authenticated] && session[:admin]
  end
end

use Rack::Session::Cookie, expire_after: settings.session_expire_after
