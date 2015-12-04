module Sinatra
  module NanoTwitter
    module Routing
      module Test

        def self.registered(app)
            #delete all rows containing test user in relations table, delete all tweets send by test users, delete all test users
            app.get '/test/reset/all' do
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

            app.get '/test/reset/testuser' do
                test_user = User.find_by(name: 'test')
                test_user = Seeds.generateTestUser if test_user.nil?
                Tweet.delete_all(sender_id: test_user.id)
                Relation.delete_all(followee_id: test_user.id)
                Relation.delete_all(follower_id: test_user.id)
                return "done"
            end

            app.get '/test/status' do
                user_count = User.count
                tweet_count = Tweet.count
                follow_count = Relation.count
                test_user = User.find_by(name: 'test')
                test_user_id = test_user.nil? ? "None" : test_user.id
                return "user_count: #{user_count}\n follows_count: #{follow_count}\n tweet_count: #{tweet_count}\n testuser.id: #{test_user_id}"
            end

            #create n fake users
            app.get '/test/seed/:n' do
                n = params['n'].to_i
                Seeds.generateUsers(n)
                return "done"
            end

            app.get '/test/tweets/:n' do
                n = params['n'].to_i
                test_user = User.find_by(name: 'test')
                return "testuser does not exist" if test_user.nil?
                Seeds.generateTweets(sender_id: test_user.id, n: n)
                return "done"
            end

            #randomly select n users to follow user “testuser”
            app.get '/test/follow/:n' do
                n = params['n'].to_i
                test_user = User.find_by(name: 'test')
                Seeds.generateRelations(followee_id: test_user[:id], n: n)
            end

            app.get '/test/tweet/:id' do
                user_id = params['id'].to_i
                Tweet.add(user_id, Faker::Lorem.sentence, nil)
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
            end

            #ask a user with given id to follow n other users
            app.get '/test/users/:id/follow/:n' do
                id = params['id'].to_i
                n = params['n'].to_i
                Seeds.generateRelations(follower_id: id, n: n)
            end

            app.get '/user/testuser' do
                testuser = User.find_by(name: 'test')
                redirect to("/user/#{testuser.id}")
            end

            app.post '/user/testuser/tweet' do
                testuser = User.find_by(name: 'test')
                Tweet.add(testuser.id, Faker::Lorem.sentence, reply_index)
            end
        end

      end
    end
  end
end
