module Sinatra
  module NanoTwitter
    module Routing
      module Api

        def self.registered(app)
            #return the recent k tweets, where k is a constance
            app.get '/api/v1/tweets/recent' do
                content_type :json
                Tweet.getTimeline({}).to_json
            end

            #return the tweet with given id
            app.get '/api/v1/tweets/:id' do
                id = params['id'].to_i
                content_type :json
                Tweet.find_by(id: id).to_json
            end

            #return the information for user with given id
            app.get '/api/v1/users/:id' do
                id = params['id'].to_i
                content_type :json
                User.find_by(id: id).to_json
            end

            #return the recent k tweets of a user of given id
            app.get '/api/v1/users/:id/tweets' do
                id = params['id'].to_i
                content_type :json
                Tweet.getTimeline(user_id: id).to_json
            end

            #return the followers of a user of given id
            app.get '/api/v1/users/:id/followers' do
                id = params['id'].to_i
                sql = "SELECT *, relations.follower_id AS id FROM users INNER JOIN relations ON users.id=relations.follower_id where relations.followee_id=#{id}"
                result = User.connection.execute(sql)
                content_type :json
                return result.to_json
            end
        end

      end
    end
  end
end
