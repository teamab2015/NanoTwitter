class Notification < ActiveRecord::Base
    belongs_to :users

    def self.notify(user_id, content)
        self.create(user_id: user_id, content: content, has_read: false, created: DateTime.now)
    end

    def self.notifyReply(user, tweet)
        sender = User.find_by(id: tweet.sender_id)
        content = "Reply from #{sender.name} - #{tweet.content}"
        self.notify(user.id, content)
    end

    def self.getUnread(user_id)
        return Notification.where(user_id: user_id, has_read: false).order(created: :desc)
    end

end
