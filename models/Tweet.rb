require_relative './Mention'
require_relative './Tag'

class Tweet < ActiveRecord::Base
    belongs_to :users
    has_many :tag_ownerships
    has_many :mentions
    has_many :tags, through: :tag_ownerships
    has_many :users, through: :mentions

    def self.add(sender_id, tweet_content, reply_index)
        tweet = Tweet.create(sender_id: sender_id,
                             content: tweet_content,
                             created: DateTime.now,
                             reply_index: self.process_reply_index(reply_index))
        Tag.processTweet(tweet)
        Mention.processTweet(tweet)
        tweet.save
    end

    def self.process_reply_index(reply_index)
        match = parse_reply_index(reply_index)
        return match.nil? ? nil : reply_index
    end

    #root_tweet_id   =  match[:root_tweet_id]
    #parent_tweet_id = match[:parent_tweet_id]
    def self.parse_reply_index(reply_index)
        return nil if reply_index.nil?
        match = /^(?<root_tweet_id>\d+)(-(?<parent_tweet_id>\d+))?$/.match(reply_index)
        return match
    end

    def self.getTimeline(params)
        user_id = params[:user_id]
        limit = params[:limit] ||= 50
        with_replies = params[:with_replies] ||= false
        wheres = []
        wheres.push("reply_index IS NULL") if !with_replies
        wheres = wheres.length == 0 ? "true" : wheres.join(" AND ")
        if user_id.nil? then
            sql = "SELECT * FROM tweets INNER JOIN users ON tweets.sender_id=users.id WHERE #{wheres} ORDER BY tweets.created DESC LIMIT #{limit}"
        else
            sql = "SELECT * FROM users, (SELECT DISTINCT tweets.* FROM tweets LEFT JOIN relations ON tweets.sender_id=relations.followee_id WHERE (follower_id=#{user_id} OR sender_id=#{user_id}) AND #{wheres} ORDER BY tweets.created DESC LIMIT #{limit}) as tweets where tweets.sender_id = users.id"
        end
        result = self.connection.execute(sql)
        return result
    end

    def self.getReplies(tweet_id)
        sql = "SELECT * FROM users, (SELECT tweets.* FROM tweets WHERE reply_index LIKE '#{tweet_id}%' OR id = #{tweet_id} ORDER BY tweets.created ASC) as tweets where tweets.sender_id = users.id"
        return self.connection.execute(sql)
    end

    TIMELINE_ISAVAILABLE_KEY = "timeline_isAvailable"
    AVAILABLE = "AVAILABLE"
    INAVAILABLE = "INAVAILABLE"
    TIMEOUT = 300

    def self.notifyTimelineExpire()
        $redis.set TIMELINE_ISAVAILABLE_KEY, INAVAILABLE
    end

    def self.getTimelineFromRedis(params)
        timeline_isAvailable = $redis.get TIMELINE_ISAVAILABLE_KEY
        return nil if timeline_isAvailable.nil? || timeline_isAvailable == INAVAILABLE
        result = $redis.get(params.to_json)
        return result
    end

    def self.updateTimelineToRedis(params, result)
        $redis.set TIMELINE_ISAVAILABLE_KEY, AVAILABLE
        $redis.expire TIMELINE_ISAVAILABLE_KEY, TIMEOUT
    end

end
