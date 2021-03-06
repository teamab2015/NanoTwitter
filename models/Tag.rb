require_relative './Tag_ownership'

class Tag < ActiveRecord::Base
    has_many :tag_ownerships
    has_many :tweets, through: :tag_ownerships

    def self.processTweet(tweet)
        tweet_content = tweet.content
        tags = tweet_content.scan(/#(?:\w|\_|\-|\.)+/)
        tags.each do |raw_tag|
            tag = Tag.find_or_create_by(word: raw_tag[1..-1])
            next if tag.nil?
            Tag_ownership.find_or_create_by(tag_id: tag.id, tweet_id: tweet.id);
            tweet_content.sub!('#'+tag.word, "<a class='tag_link' href='/tags/#{tag.id}'>#{'#'+tag.word}</a>");
        end
        tweet.content = tweet_content
        return tweet_content
    end

end
