class Tweet < ActiveRecord::Base
    belongs_to :users
    has_many :tag_ownerships
    has_many :mentions
    has_many :tags, through: :tag_ownerships
    has_many :users, through: :mentions
    has_many :replies

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
