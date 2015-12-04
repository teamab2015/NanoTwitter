require 'faker'
require 'json'
require 'date'

require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './config/initializers/redis.rb'
require 'resque'
require 'newrelic_rpm'
# require './models/User'
# require './models/Tweet'
# require './models/Relation'
# require './models/Tag'
# require './models/Tag_ownership'
# require './models/Notification'
# require './models/Mention'
# require './models/Tweet'
# require './models/User'
Dir["./models/*.rb"].each {|file| require file }
Dir["./routes/*.rb"].each {|file| require file }
Dir["./libs/*.rb"].each {|file| require file }
# require './libs/seeds'
# require './libs/authentication'
# require './libs/helper'
# require './libs/nt_cache'



set :bind, '0.0.0.0'
set :port, 4567

enable :sessions
set :session_secret, 'jsadjfajhdfjhaliuwhwreknsdfnuasjhdfguqyq34jhrfmcb'

register Sinatra::NanoTwitter::Routing::Main
register Sinatra::NanoTwitter::Routing::Login
register Sinatra::NanoTwitter::Routing::Test
register Sinatra::NanoTwitter::Routing::Api
