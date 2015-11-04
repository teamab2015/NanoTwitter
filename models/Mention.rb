require_relative './Notification'
require_relative './User'

class Mention < ActiveRecord::Base
    has_many :tweets
    has_many :users

    def self.processTweet(tweet)
        tweet_content = tweet.content
        mentions = tweet_content.scan(/@\w+/)
        mentions.each do |raw_mention|
            User.find_by(username: raw_mention[1..-1])
            if (!x.nil?) then
                Mention.find_or_create_by(tweet_id: tweet.id, user_id: user.id);
                tweet_content.sub!('@'+user.username, "<a class='mention_link' href='/user/#{user.id}'>#{'@'+user.username}</a>");
            end
        end
        if mentions[0] != nil && tweet_content.start_with?('@' + mentions[0].username) then
            Notification.notifyReply(mentions[0], tweet)
        end
        return tweet_content
    end

end
