module Sinatra
  module NanoTwitter
    module Routing
      module Main

        def self.registered(app)
            #If not logged in, then display top 50 tweets of all users, else redirect to /user/:logged_in_user_id
            app.get '/' do
                puts session['id']
                logged_in_user_id = Authentication.get_logged_in_user_id(session)
                if logged_in_user_id != nil then
                    redirect to("/user/#{logged_in_user_id}")
                else
                    @tweets = Tweet.getTimeline({})
                    erb :user
                end
            end

            #The home page of user, displaying Top 50 tweets of followed users and himself
            app.get %r{/user/(?<id>\d+)$} do
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

            app.get '/tags/:id' do
                id = params['id'].to_i
                @tag = Tag.find_by(id: id)
                sql = "SELECT * FROM users, (SELECT DISTINCT tweets.* FROM tweets INNER JOIN tag_ownerships ON tweets.id=tag_ownerships.tweet_id WHERE tag_ownerships.tag_id = #{id} ORDER BY tweets.created DESC LIMIT 50) as tweets where tweets.sender_id = users.id"
                @tweets = ActiveRecord::Base.connection.execute(sql)
                erb :tag
            end

            #notification get api
            app.get '/notifications' do
                logged_in_user_id = Authentication.get_logged_in_user_id(session)
                if (logged_in_user_id.nil?) then return status 404; end
                content_type :json
                Notification.getUnread(logged_in_user_id).to_json
            end

            #notification delete api
            app.delete '/notifications/:id' do
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

            app.post '/retweet/:tweet_id' do
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

            app.post '/tweet' do
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

            app.get '/tweet/:id' do
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
            app.post %r{/user/(?<id>\d+)/(?<action>(follow|unfollow))$} do
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
        end

      end
    end
  end
end
