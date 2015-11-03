require 'faker'
require 'date'
require_relative '../models/User'
require_relative '../models/Tweet'
require_relative '../models/Relation'

module Seeds
  DAY = 86400

  def self.generateTestUser
      user = User.create(name: 'test', username: 'test', email: 'test@test.com', password: 'test', avatar: Faker::Avatar.image)
      return user.id
  end

  def self.generateUsers(n)
      (0..n).each do |t|
          user = User.find_or_create_by(email: Faker::Internet.email)
          user.name = Faker::Name.name
          user.username = Faker::Internet.user_name
          user.password = Faker::Internet.password
          user.avatar = Faker::Avatar.image
          user.save
      end
  end

  def self.generateTweets(sender_id: nil, n: 20)
      if (sender_id.is_a?(Integer) && n.is_a?(Integer)) then
          Faker::Lorem.sentences(n).each do |sentence|
              Tweet.create(sender_id: sender_id, content: sentence, created: DateTime.now - 7 + Rational(rand(0..DAY*7), DAY))
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
      end
      if (followee_id.is_a?(Integer) && n.is_a?(Integer)) then
          User.where("id != #{followee_id}").order("RANDOM()").limit(n).each do |user|
              Relation.find_or_create_by(followee_id: followee_id, follower_id: user[:id])
          end
      end
      if (follower_id.is_a?(Integer) && n.is_a?(Integer)) then
          User.where("id != #{follower_id}").order("RANDOM()").limit(n).each do |user|
              Relation.find_or_create_by(followee_id: user[:id], follower_id: follower_id)
          end
      end
  end


end
