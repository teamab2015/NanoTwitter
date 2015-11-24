require_relative './Mention'
require_relative './Tag'

module LoggedJob
  def before_perform_log_job(*args)
    puts "About to perform #{self} with #{args.inspect}"
  end
end

module FailedJob
  def on_failure_retry(e, *args)
    puts "Performing #{self} caused an exception (#{e})."
    #Resque.enqueue self, *args
  end
end

class Tweet < ActiveRecord::Base
    extend LoggedJob
    extend FailedJob
    belongs_to :users
    has_many :tag_ownerships
    has_many :mentions
    has_many :tags, through: :tag_ownerships
    has_many :users, through: :mentions
    @queue = :tweet_add

    def self.add(sender_id, tweet_content, reply_index)
        created = DateTime.now
        NT_Cache.notifyRawTweetAdd(sender_id, tweet_content, reply_index, created)
        Resque.enqueue(Tweet, 'write', sender_id, tweet_content, reply_index, created)
    end

    def self.write(*args)
        sender_id, tweet_content, reply_index, created = *args
        tweet = Tweet.create(sender_id: sender_id,
                             content: tweet_content,
                             created: created,
                             reply_index: self.process_reply_index(reply_index))
        Tag.processTweet(tweet)
        Mention.processTweet(tweet)
        NT_Cache.notifyTweetAdd(tweet)
        tweet.save
    end

    def self.perform(*args)
        method = self.method(*args.first)
        method.call(*args[1..-1])
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
        result = NT_Cache.getTimeline(user_id, limit, with_replies)
        return result if result != nil
        result = self.getTimelineFromDB(user_id, limit, with_replies)
        NT_Cache.notifyFetchTimeLineFromDB(user_id, limit, with_replies, result)
        return result
    end

    def self.getTimelineFromDB(user_id, limit, with_replies)
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

end
