require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require 'faker'
require 'json'
require './models/User'
require './models/Tweet'
require './models/Relation'
require 'date'

set :bind, '0.0.0.0'
set :port, 4567

enable :sessions
set :session_secret, 'jsadjfajhdfjhaliuwhwreknsdfnuasjhdfguqyq34jhrfmcb'

#If not logged in, then display top 50 tweets of all users, else redirect to /user/:logged_in_user_id
get '/' do
    id = session[:user_id]
    @loggedin = id != nil
    if @loggedin then
        redirect to("/user/#{id}")
    else
        @tweets = Tweet.order(created: :desc).limit(50)
        @tweets.to_a.map!{|tweet| tweet.attributes }
                    .each{|tweet| tweet["user"] = User.find_by(id: tweet["sender_id"]).attributes}
        erb :user
    end
end

#display register page
get '/user/register' do
    erb :register
end

post '/user/register' do
    name = params[:name]
    email = params[:email]
    password = params[:password]
    if (User.find_by(email: email) != nil) then
        redirect to("/user/register")
    else
        User.create(name: name, email: email, password: password, avatar: Faker::Avatar.image)
        redirect to("/")
    end
end

#The home page of user, displaying Top 50 tweets of followed users and himself
get '/user/:id' do
    id = params['id'].to_i
    logged_in_user_id = session[:user_id]
    @isHome = logged_in_user_id == id
    @loggedin = logged_in_user_id != nil
    if (@loggedin) then
        @logged_in_user = User.find_by(id: logged_in_user_id).attributes
        @isFollowed = Relation.find_by(followee_id: id, follower_id: logged_in_user_id) != nil
    end
    #TODO catch not found case
    @user = User.find_by(id: id)
    #user_id = @user[:id]
    #sql = "SELECT tweets.* FROM tweets INNER JOIN relations ON tweets.sender_id=relations.followee_id WHERE follower_id=#{user_id} OR sender_id=#{user_id} ORDER BY tweets.created DESC LIMIT 50"
    #@tweets = ActiveRecord::Base.connection.execute(sql)
    #@tweets = @tweets.to_a.each{|tweet| tweet["user"] = User.find_by(id: tweet["sender_id"]).attributes}
    @tweets = Tweet.where(sender_id: id).order(created: :desc).limit(50)
    @tweets.to_a.map!{|tweet| tweet.attributes }
                .each{|tweet| tweet["user"] = @user.attributes}
    erb :user
end

#display the login page, after logging in redirect to /user/:id
get '/login' do
end

post '/user/:id/tweet' do
    sender_id = params['id'].to_i
    if (session[:user_id] != nil && session[:user_id] == sender_id) then
        tweet = params[:tweet]
        Tweet.create(sender_id: sender_id, content: tweet, created: DateTime.now)
        redirect to("/user/#{sender_id}")
    else
        return status 403
    end
end

post '/login' do
    email = params[:email]
    password = params[:password]
    user = User.find_by(email: email, password: password)
    if (user == nil) then
        redirect to('/')
    else
        session[:user_id] = user[:id]
        redirect to("/user/#{user[:id]}")
    end
end

#log in the user with user_id, may accept requests with password parameter to log in
get '/login/:id' do
end

#log out the current user, after logging out redirect to /
get '/logout' do
    session[:user_id] = nil
    redirect to("/")
end

#delete all rows containing test user in relations table, delete all tweets send by test users, delete all test users
get '/test/reset' do
    User.destroy_all
    User.create(name: 'test', email: 'test@test.com', password: 'test', avatar: Faker::Avatar.image)
    return "done"
end

#create n fake users
get '/test/seed/:n' do
    n = params['n'].to_i
    (0..n).each do |t|
        User.create(name: Faker::Name.name, email: Faker::Internet.email, password: Faker::Internet.password, avatar: Faker::Avatar.image)
    end
    return "done"
end

#user “testuser” generates n new fake tweets
get '/test/tweets/:n' do
    n = params['n'].to_i
    user = User.find_by(name: 'test')
    if (user == nil) then return; end
    Faker::Lorem.sentences(n).each do |sentence|
        Tweet.create(sender_id: user[:id], content: sentence, created: DateTime.now)
    end
    return "done"
end

#randomly select n users to follow user “testuser”
get '/test/follow/:n' do
    n = params['n'].to_i
    test_user = User.find_by(name: 'test')
    User.where("name != 'test'").order("RANDOM()").limit(n).each do |user|
        Relation.create(followee_id: test_user[:id], follower_id: user[:id])
    end
    return "done"
end

#ask a user with given id to follow n other users
get '/test/users/:id/follow/:n' do
    id = params['id'].to_i
    n = params['n'].to_i
    User.where("id != #{id}").order("RANDOM()").limit(n).each do |user|
        Relation.create(followee_id: user[:id], follower_id: id)
    end
    return "done"
end

#diaplay all the fake users
get '/test/users' do
    users = User.all
    content_type :json
    return users.to_json
end

#return the recent k tweets, where k is a constance
get '/tweets/recent' do
    k = 50
    content_type :json
    Tweet.order(created: :desc).limit(k).to_json
end

#return the tweet with given id
get '/tweets/:id' do
    id = params['id'].to_i
    content_type :json
    Tweet.find_by(id: id).to_json
end

#TODO use regex to merge '/tweets/:id' and '/users/:id'
#return the information for user with given id
get '/users/:id' do
    id = params['id'].to_i
    content_type :json
    User.find_by(id: id).to_json
end

#return the recent k tweets of a user of given id
get '/users/:id/tweets' do
    id = params['id'].to_i
    k = 50
    content_type :json
    Tweet.where(sender_id: id).order(created: :desc).limit(k).to_json
end
