require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require 'faker'
require 'json'
require './config/initializers/redis.rb'
require 'resque'
require './models/User'
require './models/Tweet'
require './models/Relation'
require './models/Tag'
require './models/Tag_ownership'
require './models/Notification'
require './models/Mention'
require './models/Tweet'
require './models/User'
require 'date'
require './libs/seeds'
require './libs/authentication'
require './libs/helper'
require 'newrelic_rpm'
require './libs/nt_cache'

set :bind, '0.0.0.0'
set :port, 4567

enable :sessions
set :session_secret, 'jsadjfajhdfjhaliuwhwreknsdfnuasjhdfguqyq34jhrfmcb'

#If not logged in, then display top 50 tweets of all users, else redirect to /user/:logged_in_user_id
get '/' do
    puts session['id']
    logged_in_user_id = Authentication.get_logged_in_user_id(session)
    if logged_in_user_id != nil then
        redirect to("/user/#{logged_in_user_id}")
    else
        @tweets = Tweet.getTimeline({})
        erb :user
    end
end

#display register page
get '/user/register' do
    logged_in_user_id = Authentication.get_logged_in_user_id(session)
    if logged_in_user_id.nil? then
        erb :register
    else
        redirect to("/user/#{logged_in_user_id}")
    end
end

post '/user/register' do
    begin
        User.register(name: params[:name],
                      email: params[:email],
                      password: params[:password],
                      username: params[:username])
        redirect to("/")
    rescue => error
        @error_message = error.message
        erb :register
    end
end

#The home page of user, displaying Top 50 tweets of followed users and himself
get %r{/user/(?<id>\d+)$} do
    @logged_in_user = Authentication.get_logged_in_user(session)
    #if (@logged_in_user.nil?) then redirect to("/logout"); end
    @user = User.find_by(id: params['id'].to_i)
    if (@user.nil?) then return status 404; end
    if @logged_in_user != nil then
        @isFollowed = Relation.find_by(followee_id: @user.id, follower_id: @logged_in_user.id) != nil
        @isHome = @logged_in_user.id == @user.id
    end
    @tweets = Tweet.getTimeline(user_id: @user.id)
    erb :user
end

get '/tags/:id' do
    id = params['id'].to_i
    @tag = Tag.find_by(id: id)
    sql = "SELECT * FROM users, (SELECT DISTINCT tweets.* FROM tweets INNER JOIN tag_ownerships ON tweets.id=tag_ownerships.tweet_id WHERE tag_ownerships.tag_id = #{id} ORDER BY tweets.created DESC LIMIT 50) as tweets where tweets.sender_id = users.id"
    @tweets = ActiveRecord::Base.connection.execute(sql)
    erb :tag
end

#notification get api
get '/notifications' do
    logged_in_user_id = Authentication.get_logged_in_user_id(session)
    if (logged_in_user_id.nil?) then return status 404; end
    content_type :json
    Notification.getUnread(logged_in_user_id).to_json
end

#notification delete api
delete '/notifications/:id' do
    notification_id = params['id'].to_i
    logged_in_user_id = Authentication.get_logged_in_user_id(session)
    if (logged_in_user_id.nil?) then return status 404; end
    result = notification_id == -1 ? Notification.clearAll(logged_in_user_id) : Notification.clear(notification_id, logged_in_user_id)
    if result then
        return status 200
    else
        return status 404
    end
end

post '/retweet/:tweet_id' do
    sender_id = Authentication.get_logged_in_user_id(session)
    tweet_id = params['tweet_id'].to_i
    if !sender_id.nil? then
        tweet = Tweet.find_by(id: tweet_id);
        if tweet.nil? then
            return status 403
        end
        Tweet.add(sender_id, tweet['content'], nil)
        return status 200
    else
        return status 403
    end
end

#display the login page, after logging in redirect to /user/:id
get '/login' do
    redirect to("/")
end

post '/tweet' do
    sender_id = Authentication.get_logged_in_user_id(session)
    if !sender_id.nil? then
        tweet_content = params[:tweet]
        reply_index = params[:reply_index]
        tweet_prefix = params[:tweet_prefix]
        tweet_content = tweet_prefix + tweet_content if tweet_prefix != nil
        Tweet.add(sender_id, tweet_content, reply_index)
        return status 200 if params[:avoid_redirect]
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
    id = params['id'].to_i
    session[:user_id] = id
    redirect to("/user/#{id}")
end

#log out the current user, after logging out redirect to /
get '/logout' do
    session[:user_id] = nil
    redirect to("/")
end

get '/tweet/:id' do
    @logged_in_user = Authentication.get_logged_in_user(session)
    id = params['id'].to_i
    @taget_tweet = Tweet.find_by(id: id)
    return status 404 if @taget_tweet.nil?
    match = Tweet.parse_reply_index(@taget_tweet.reply_index)
    root_tweet_id = match.nil? ? @taget_tweet.id : match[:root_tweet_id]
    @tweets = Tweet.getReplies(root_tweet_id)
    partial = params[:partial]
    if partial.nil? then
        erb :tweet
    else
        erb :tweets_modal
    end
end

#follow/unfollow the user of given id
post %r{/user/(?<id>\d+)/(?<action>(follow|unfollow))$} do
    followee_id = params['id'].to_i
    follower_id = session[:user_id]
    return status 403 if follower_id.nil?
    return status 403 if followee_id == follower_id
    if params['action'] == "follow" then
        Relation.find_or_create_by(followee_id: followee_id, follower_id: follower_id)
    else
        Relation.where(followee_id: followee_id, follower_id: follower_id).delete_all
    end
    return status 200
end

#delete all rows containing test user in relations table, delete all tweets send by test users, delete all test users
get '/test/reset/all' do
    Mention.delete_all
    Notification.delete_all
    Relation.delete_all
    Tag_ownership.delete_all
    Tag.delete_all
    Tweet.delete_all
    User.delete_all
    Seeds.generateTestUser
    return "done"
end

get '/test/reset/testuser' do
    test_user = User.find_by(name: 'test')
    test_user = Seeds.generateTestUser if test_user.nil?
    Tweet.delete_all(sender_id: test_user.id)
    Relation.delete_all(followee_id: test_user.id)
    Relation.delete_all(follower_id: test_user.id)
    return "done"
end

get '/test/status' do
    user_count = User.count
    tweet_count = Tweet.count
    follow_count = Relation.count
    test_user = User.find_by(name: 'test')
    test_user_id = test_user.nil? ? "None" : test_user.id
    return "user_count: #{user_count}\n follows_count: #{follow_count}\n tweet_count: #{tweet_count}\n testuser.id: #{test_user_id}"
end

#create n fake users
get '/test/seed/:n' do
    n = params['n'].to_i
    Seeds.generateUsers(n)
    return "done"
end

get '/test/tweets/:n' do
    n = params['n'].to_i
    test_user = User.find_by(name: 'test')
    return "testuser does not exist" if test_user.nil?
    Seeds.generateTweets(sender_id: test_user.id, n: n)
    return "done"
end

#randomly select n users to follow user “testuser”
get '/test/follow/:n' do
    n = params['n'].to_i
    test_user = User.find_by(name: 'test')
    Seeds.generateRelations(followee_id: test_user[:id], n: n)
end

get '/test/tweet/:id' do
    user_id = params['id'].to_i
    Tweet.add(user_id, Faker::Lorem.sentence, nil)
end

get '/test/timeline/:total_user_count' do
    total_user_count = params['total_user_count'].to_i
    prng = Random.new
    content_type :json
    Tweet.getTimeline(user_id: prng.rand(total_user_count)).to_json
end

get '/test/user/:id/timeline' do
    user_id = params['id'].to_i
    content_type :json
    Tweet.getTimeline(user_id: user_id).to_json
end

#let user of given id generate n tweets
get '/test/user/:id/tweet' do
    user_id = params['id'].to_i
    Tweet.add(user_id, Faker::Lorem.sentence, nil)
end

#ask a user with given id to follow n other users
get '/test/users/:id/follow/:n' do
    id = params['id'].to_i
    n = params['n'].to_i
    Seeds.generateRelations(follower_id: id, n: n)
end

get '/user/testuser' do
    testuser = User.find_by(name: 'test')
    redirect to("/user/#{testuser.id}")
end

post '/user/testuser/tweet' do
    testuser = User.find_by(name: 'test')
    Tweet.add(testuser.id, Faker::Lorem.sentence, reply_index)
end

#return the recent k tweets, where k is a constance
get '/api/v1/tweets/recent' do
    content_type :json
    Tweet.getTimeline({}).to_json
end

#return the tweet with given id
get '/api/v1/tweets/:id' do
    id = params['id'].to_i
    content_type :json
    Tweet.find_by(id: id).to_json
end

#return the information for user with given id
get '/api/v1/users/:id' do
    id = params['id'].to_i
    content_type :json
    User.find_by(id: id).to_json
end

#return the recent k tweets of a user of given id
get '/api/v1/users/:id/tweets' do
    id = params['id'].to_i
    content_type :json
    Tweet.getTimeline(user_id: id).to_json
end
