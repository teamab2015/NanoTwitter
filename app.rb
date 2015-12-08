require 'faker'
require 'json'
require 'date'

require 'sinatra'
require 'sinatra/activerecord'
require 'resque'
require 'newrelic_rpm'
require './config/environments'
require './config/initializers/redis.rb'
require './config/initializers/resque-pool.rb'


Dir["./models/*.rb"].each {|file| require file }
Dir["./routes/*.rb"].each {|file| require file }
Dir["./libs/*.rb"].each {|file| require file }
Dir["./helpers/*.rb"].each {|file| require file }

set :bind, '0.0.0.0'
set :port, 4567

enable :sessions
set :session_secret, 'jsadjfajhdfjhaliuwhwreknsdfnuasjhdfguqyq34jhrfmcb'

helpers Sinatra::NanoTwitter::TestHelper

register Sinatra::NanoTwitter::Routing::Main
register Sinatra::NanoTwitter::Routing::Login
register Sinatra::NanoTwitter::Routing::Test
register Sinatra::NanoTwitter::Routing::Api
