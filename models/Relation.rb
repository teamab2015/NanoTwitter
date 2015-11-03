class Relation < ActiveRecord::Base
    belongs_to :users

    def self.add(p)
        followee_id = p[:followee_id]
        follower_id = p[:follower_id]
        return self.find_or_create_by({follower_id: follower_id, followee_id: followee_id})
    end

    def self.exist?(p)
        followee_id = p[:followee_id]
        follower_id = p[:follower_id]
        return self.find_by({follower_id: follower_id, followee_id: followee_id}) != nil
    end
end
