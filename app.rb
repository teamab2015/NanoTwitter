require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require 'faker'
require 'json'
require './models/User'
require './models/Tweet'
require './models/Relation'
require './models/Tag'
require './models/Tag_ownership'
require './models/Notification'
require './models/Mention'
require './models/Reply'
require './models/Tweet'
require './models/User'
require 'date'
require './libs/seeds'
require './libs/authentication'
require './libs/helper'

set :bind, '0.0.0.0'
set :port, 4567

enable :sessions
set :session_secret, 'jsadjfajhdfjhaliuwhwreknsdfnuasjhdfguqyq34jhrfmcb'

#If not logged in, then display top 50 tweets of all users, else redirect to /user/:logged_in_user_id
get '/' do
    puts session['id']
    logged_in_user_id = Authentication.get_logged_in_user_id(session, params)
    if logged_in_user_id != nil then
        redirect to("/user/#{logged_in_user_id}")
    else
        @tweets = Tweet.getTimeline
        erb :user
    end
end

#display register page
get '/user/register' do
    erb :register
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
get '/user/:id' do
    @logged_in_user = Authentication.get_logged_in_user(session, params)
    #if (@logged_in_user.nil?) then redirect to("/logout"); end
    @user = User.find_by(id: params['id'].to_i)
    if (@user.nil?) then return status 404; end
    if @logged_in_user != nil then
        @isFollowed = Relation.find_by(followee_id: @user.id, follower_id: @logged_in_user.id) != nil
        @isHome = @logged_in_user.id == @user.id
    end
    @tweets = Tweet.getTimeline(@user.id)
    erb :user
end

get '/tags/:id' do
    id = params['id'].to_i
    @tag = Tag.find_by(id: id)
    sql = "SELECT * FROM users, (SELECT DISTINCT tweets.* FROM tweets INNER JOIN tag_ownerships ON tweets.id=tag_ownerships.tweet_id WHERE tag_ownerships.tag_id = #{id} ORDER BY tweets.created DESC LIMIT 50) as tweets where tweets.sender_id = users.id"
    @tweets = ActiveRecord::Base.connection.execute(sql)
    erb :tag
end

#notification api
get '/user/:id/notifications' do
    logged_in_user_id = Authentication.get_logged_in_user_id(session, params)
    if (logged_in_user_id.nil?) then return status 404; end
    content_type :json
    Notification.where(user_id: id, has_read: false).order(created: :desc).to_json
end


#display the login page, after logging in redirect to /user/:id
get '/login' do
    redirect to("/")
end

post '/user/:id/tweet' do
    sender_id = params['id'].to_i
    if (session[:user_id] != nil && session[:user_id] == sender_id) then
        tweet_content = params[:tweet]
        tweet = Tweet.create(sender_id: sender_id, content: tweet_content, created: DateTime.now)

        mentions = tweet_content.scan(/@\w+/)
        tags = tweet_content.scan(/#\w+/)
        tags.map!{ |raw_tag| Tag.find_or_create_by(word: raw_tag[1..-1]) }
            .select{ |x| !x.nil?}
            .each{ |tag| Tag_ownership.find_or_create_by(tag_id: tag.id, tweet_id: tweet.id) }
        tags.select{ |x| !x.nil?}
            .each{ |tag| tweet_content.sub!('#'+tag.word, "<a class='tag_link' href='/tags/#{tag.id}'>#{'#'+tag.word}</a>") }
        mentions.map!{ |raw_mention| User.find_by(username: raw_mention[1..-1]) }
            .select{ |x| !x.nil?}
            .each{ |user| Mention.find_or_create_by(tweet_id: tweet.id, user_id: user.id)}
        mentions.select{ |x| !x.nil?}
                .each{ |user| tweet_content.sub!('@'+user.username, "<a class='mention_link' href='/user/#{user.id}'>#{'@'+user.username}</a>") }
        puts tweet_content
        Tweet.update(tweet.id, content: tweet_content)
        reply_index = params[:reply_index]
        if reply_index != nil && Reply.check_index(reply_index) then
            Reply.find_or_create_by(reply_index: reply_index, tweet_id: tweet.id)
        end
        if mentions[0] != nil && tweet_content.start_with?('@' + mentions[0].username) then
            Notification.notifyReply(mentions[0], tweet)
        end
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
    redirect to("/users/#{id}")
end

#log out the current user, after logging out redirect to /
get '/logout' do
    session[:user_id] = nil
    redirect to("/")
end

#follow the user of given id
post '/user/:id/follow' do
    followee_id = params['id'].to_i
    follower_id = session[:user_id]
    if (follower_id.nil?) then
        return status 403
    end
    Relation.find_or_create_by(followee_id: followee_id, follower_id: follower_id)
    return status 200
end

#unfollow the user of given id
post '/user/:id/unfollow' do
    followee_id = params['id'].to_i
    follower_id = session[:user_id]
    if (follower_id.nil?) then
        return status 403
    end
    Relation.where(followee_id: followee_id, follower_id: follower_id).delete_all
    return status 200
end

#delete all rows containing test user in relations table, delete all tweets send by test users, delete all test users
get '/test/reset' do
    User.destroy_all
    Seeds.generateTestUser
    return "done"
end

#create n fake users
get '/test/seed/:n' do
    n = params['n'].to_i
    Seeds.generateUsers(n)
    return "done"
end

#each user generates n tweets
get '/test/tweets/:n' do
    n = params['n'].to_i
    Seeds.generateTweets(n: n)
    #user = User.find_by(name: 'test')
    #if (user == nil) then return; end
    #redirect to("/test/users/#{user[:id]}/tweets/#{n}")
    return "done"
end

#let user of given id generate n tweets
get '/test/users/:id/tweets/:n' do
    n = params['n'].to_i
    user_id = params['id'].to_i
    Seeds.generateTweets(sender_id: user_id, n: n)
    return "done"
end

#randomly select n users to follow user “testuser”
get '/test/follow/:n' do
    n = params['n'].to_i
    test_user = User.find_by(name: 'test')
    Seeds.generateRelations(followee_id: test_user[:id], n: n)
    return "done"
end

#ask a user with given id to follow n other users
get '/test/users/:id/follow/:n' do
    id = params['id'].to_i
    n = params['n'].to_i
    Seeds.generateRelations(follower_id: id, n: n)
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
