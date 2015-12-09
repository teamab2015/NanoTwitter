require "json"

module NT_Cache

  def self.setup()
      $redis.flushall
      $redis.pipelined {
          Relation.all.each {|x| self.addFollower(x.followee_id, x.follower_id)}
          User.all.each {|x| self.addUser(x); self.addFollower(x.id, x.id)}
      }
  end

  def self.addUser(user)
      key = "user-#{user.id}"
      $redis.set(key, user.to_json)
      self.addFollower(user.id, user.id)
  end

  def self.getUser(user_id)
      key = "user-#{user_id}"
      JSON.parse($redis.get(key))
  end

  def self.addFollower(followee_id, follower_id)
      key = "followers-#{followee_id}"
      $redis.sadd(key, follower_id)
  end

  def self.removeFollower(followee_id, follower_id)
      key = "followers-#{followee_id}"
      $redis.srem(key, follower_id)
  end

  def self.getFollowers(followee_id)
      key = "followers-#{followee_id}"
      return ($redis.smembers(key)) || []
  end

  def self.getTimeline(user_id, limit, with_replies)
      key = user_id.nil? ? "homeTimeline" : "userTimeline-#{user_id}"
      if $redis.exists(key) then
          result = $redis.lrange(key, -50, -1)
          return result.map {|x| JSON.parse(x)}
      else
          return nil
      end
  end

  def self.notifyFetchTimeLineFromDB(user_id, limit, with_replies, result)
      key = user_id.nil? ? "homeTimeline" : "userTimeline-#{user_id}"
      return if $redis.exists(key)
      $redis.pipelined{ result.each{ |x| $redis.rpush(key, x.to_json) } }
      $redis.expire(key, 120)
  end

  def self.perform(*args)
      method = self.method(*args.first)
      method.call(*args[1..-1])
  end

  def self.notifyTweetAdd(tweet)
  end

  def self.notifyRawTweetAdd(sender_id, tweet_content, reply_index, created)
      tweet = {sender_id: sender_id, content: tweet_content, reply_index: reply_index, created: created}
      user  = self.getUser(sender_id)
      user.delete("id")
      tweet = tweet.merge(user)
      tweet = tweet.to_json
      followers = self.getFollowers(sender_id)
      $redis.pipelined {
          $redis.lpush("homeTimeline", tweet)
          $redis.ltrim("homeTimeline", -50, -1);
          if followers != nil then
              followers.each {|follower_id| key="userTimeline-#{follower_id}";
                                            $redis.lpush(key, tweet);
                                            $redis.ltrim(key, -50, -1);}
          end
      }
  end

end

if ENV['RAILS_ENV'] != 'test' && ENV['ignore_cache_setup'].nil? then
    puts 'NT_Cache.setup'
    NT_Cache.setup
end
