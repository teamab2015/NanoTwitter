class Notification < ActiveRecord::Base
    belongs_to :users

    def self.notify(user_id, content)
        self.create(user_id: user_id, content: content, has_read: false, created: DateTime.now)
    end

    def self.notifyReply(user, tweet)
        sender = User.find(id: tweet.sender)
        content = "Reply from #{sender.name} - #{tweet.content}"
        self.notify(user.id, content)
    end


end
