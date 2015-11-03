require_relative './Mention'
require_relative './Notification'
require_relative './Reply'
require_relative './Tag'
require_relative './Tag_ownership'
require_relative './User'

class Tweet < ActiveRecord::Base
    belongs_to :users
    has_many :tag_ownerships
    has_many :mentions
    has_many :tags, through: :tag_ownerships
    has_many :users, through: :mentions
    has_many :replies

    def self.add(sender_id, tweet_content, reply_index)
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
        Tweet.update(tweet.id, content: tweet_content)
        if reply_index != nil && Reply.check_index(reply_index) then
            Reply.find_or_create_by(reply_index: reply_index, tweet_id: tweet.id)
        end
        if mentions[0] != nil && tweet_content.start_with?('@' + mentions[0].username) then
            Notification.notifyReply(mentions[0], tweet)
        end
    end

    def self.getRecent
        sql = "SELECT * FROM tweets INNER JOIN users ON tweets.sender_id=users.id ORDER BY tweets.created DESC LIMIT 50"
        return self.connection.execute(sql)
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
