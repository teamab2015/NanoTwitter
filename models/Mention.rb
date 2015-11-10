require_relative './Notification'
require_relative './User'

class Mention < ActiveRecord::Base
    has_many :tweets
    has_many :users

    def self.processTweet(tweet)
        tweet_content = tweet.content
        mentions = tweet_content.scan(/@(?:\w|\_|\-|\.)+/)
        mentions.each_with_index do |raw_mention, index|
            user = User.find_by(username: raw_mention[1..-1])
            next if user.nil?
            Notification.notifyReply(user, tweet) if index == 0 && tweet_content.start_with?('@' + user.username)
            Mention.find_or_create_by(tweet_id: tweet.id, user_id: user.id);
            tweet_content.sub!('@'+user.username, "<a class='mention_link' href='/user/#{user.id}'>#{'@'+user.username}</a>");
        end
        tweet.content = tweet_content
        return tweet_content
    end

end
