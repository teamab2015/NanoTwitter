module Sinatra
  module NanoTwitter
    module Routing
      module Test

        def self.registered(app)
            #delete all rows containing test user in relations table, delete all tweets send by test users, delete all test users
            app.get '/test/reset/all' do
                $redis.flushall
                Mention.delete_all
                Notification.delete_all
                Relation.delete_all
                Tag_ownership.delete_all
                Tag.delete_all
                Tweet.delete_all
                User.delete_all
                clear_testuser_id
                id = testuser_id()
                return "done testuser_id=#{id}"
            end

            app.get '/test/reset/testuser' do
                $redis.flushall
                Tweet.delete_all(sender_id: testuser_id)
                Relation.delete_all(followee_id: testuser_id)
                Relation.delete_all(follower_id: testuser_id)
                id = testuser_id()
                return "done testuser_id=#{id}"
            end

            app.get '/test/status' do
                user_count = User.count
                tweet_count = Tweet.count
                follow_count = Relation.count
                return "user_count: #{user_count}\n follows_count: #{follow_count}\n tweet_count: #{tweet_count}\n testuser.id: #{testuser_id || 'None'}"
            end

            #create n fake users
            app.get '/test/seed/:n' do
                n = params['n'].to_i
                Seeds.useRedis(true).generateUsers(n)
                return "done"
            end

            app.get '/test/tweets/:n' do
                n = params['n'].to_i
                Seeds.generateTweets(sender_id: testuser_id, n: n, useRedis: true)
                return "done testuser_id=#{testuser_id}"
            end

            #randomly select n users to follow user “testuser”
            app.get '/test/follow/:n' do
                n = params['n'].to_i
                Seeds.useRedis(true).generateRelations(followee_id: testuser_id, n: n)
                return "done"
            end

            app.get '/user/testuser' do
                redirect to("/user/#{testuser_id}")
            end

            app.post '/user/testuser/tweet' do
                Tweet.add(testuser_id, Faker::Lorem.sentence, nil)
            end

            ##################################################################
            #additional test interface

            app.get '/test/tweet/:id' do
                user_id = params['id'].to_i
                Tweet.add(user_id, Faker::Lorem.sentence, nil)
                return "done"
            end

            app.get '/test/timeline/:total_user_count' do
                total_user_count = params['total_user_count'].to_i
                prng = Random.new
                content_type :json
                Tweet.getTimeline(user_id: prng.rand(total_user_count)).to_json
            end

            app.get '/test/user/:id/timeline' do
                user_id = params['id'].to_i
                content_type :json
                Tweet.getTimeline(user_id: user_id).to_json
            end

            #let user of given id generate n tweets
            app.get '/test/user/:id/tweet' do
                user_id = params['id'].to_i
                Tweet.add(user_id, Faker::Lorem.sentence, nil)
                return "done"
            end

            #ask a user with given id to follow n other users
            app.get '/test/users/:id/follow/:n' do
                id = params['id'].to_i
                n = params['n'].to_i
                Seeds.generateRelations(follower_id: id, n: n)
                return "done"
            end

        end

      end
    end
  end
end
