require 'faker'
require 'date'
require_relative '../models/User'
require_relative '../models/Tweet'
require_relative '../models/Relation'

module Seeds
  DAY = 86400
  @@useRedis = false

  def self.useRedis(x)
      @@useRedis = x
      return self
  end

  def self.generateTestUser
      user = User.create(name: 'test', username: 'test', email: 'test@test.com', password: 'test', avatar: Faker::Avatar.image)
      NT_Cache.addUser(user) if @@useRedis
      return user.id
  end

  def self.generateUsers(n)
      l = (0..n-1).map{|x| {name: Faker::Name.name,
                    email: Faker::Internet.email,
                    username: Faker::Internet.user_name,
                    password: Faker::Internet.password,
                    avatar: Faker::Avatar.image} }
      users = User.create(l)
      if @@useRedis then
          $redis.pipelined {
              users.each{ |u| NT_Cache.addUser(u) }
          }
      end
  end

  def self.generateTweets(sender_id: nil, n: 20)
      if (sender_id.is_a?(Integer) && n.is_a?(Integer)) then
          Faker::Lorem.sentences(n).each do |sentence|
              if @@useRedis then
                  Tweet.add(sender_id, sentence, nil)
              else
                  Tweet.create(sender_id: sender_id, content: sentence, created: DateTime.now - 7 + Rational(rand(0..DAY*7), DAY))
              end
          end
      end
      if (sender_id.nil? && n.is_a?(Integer)) then
          User.all.each do |user|
              generateTweets(sender_id: user[:id], n: n)
          end
      end
  end

  def self.generateRelations(followee_id: nil, follower_id: nil, n: 20)
      if (followee_id.is_a?(Integer) && follower_id.is_a?(Integer)) then
          Relation.find_or_create_by(followee_id: followee_id, follower_id: follower_id)
          NT_Cache.addFollower(followee_id, follower_id) if @@useRedis
      end
      if (followee_id.is_a?(Integer) && n.is_a?(Integer)) then
          users = User.where("id != #{followee_id}").order("RANDOM()").limit(n)
          l = users.map{|user| {followee_id: followee_id, follower_id: user[:id]}}
          Relation.create(l)
          $redis.pipelined{users.each{|user| NT_Cache.addFollower(followee_id, user[:id])}} if @@useRedis
      end
      if (follower_id.is_a?(Integer) && n.is_a?(Integer)) then
          users = User.where("id != #{follower_id}").order("RANDOM()").limit(n)
          l = users.map{|user| {followee_id: user[:id], follower_id: follower_id}}
          Relation.create(l)
          $redis.pipelined{users.each{|user| NT_Cache.addFollower(user[:id], follower_id)}} if @@useRedis
      end
  end


end
