require_relative './Mention'
require_relative './Reply'
require_relative './Tag'

class Tweet < ActiveRecord::Base
    belongs_to :users
    has_many :tag_ownerships
    has_many :mentions
    has_many :tags, through: :tag_ownerships
    has_many :users, through: :mentions
    has_many :replies

    def self.add(sender_id, tweet_content, reply_index)
        tweet = Tweet.create(sender_id: sender_id, content: tweet_content, created: DateTime.now)
        Tweet.update(tweet.id, content: tweet_content)
        tweet_content = Tag.processTweet(tweet)
        tweet_content = Mention.processTweet(tweet)
        if reply_index != nil && Reply.check_index(reply_index) then
            Reply.find_or_create_by(reply_index: reply_index, tweet_id: tweet.id)
        end
    end

    def self.getTimeline(*args)
        user_id = args[0]
        if user_id.nil? then
            sql = "SELECT * FROM tweets INNER JOIN users ON tweets.sender_id=users.id ORDER BY tweets.created DESC LIMIT 50"
        else
            sql = "SELECT * FROM users, (SELECT DISTINCT tweets.* FROM tweets LEFT JOIN relations ON tweets.sender_id=relations.followee_id WHERE follower_id=#{user_id} OR sender_id=#{user_id} ORDER BY tweets.created DESC LIMIT 50) as tweets where tweets.sender_id = users.id"
        end
        return self.connection.execute(sql)
    end

end
