require_relative './Tag_ownership'

class Tag < ActiveRecord::Base
    has_many :tag_ownerships
    has_many :tweets, through: :tag_ownerships

    def self.processTweet(tweet)
        tweet_content = tweet.content
        tags = tweet_content.scan(/#\w+/)
        tags.map!{ |raw_tag| Tag.find_or_create_by(word: raw_tag[1..-1]) }
            .select{ |x| !x.nil?}
            .each{ |tag| Tag_ownership.find_or_create_by(tag_id: tag.id, tweet_id: tweet.id);
                        tweet_content.sub!('#'+tag.word, "<a class='tag_link' href='/tags/#{tag.id}'>#{'#'+tag.word}</a>");}
        return tweet_content
    end

end
