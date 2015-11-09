require 'json'

class Notification < ActiveRecord::Base
    belongs_to :users

    def self.notify(user_id, content)
        self.create(user_id: user_id, content: content, has_read: false, created: DateTime.now)
    end

    def self.notifyReply(user, tweet) #forward to tweet view
        sender = User.find_by(id: tweet.sender_id)
        content = {content: "Reply from #{sender.name} - #{tweet.content}", link: "/tweets/#{tweet.id}"}
        content = content.to_json
        self.notify(user.id, content)
    end

    def self.getUnread(user_id)
        return Notification.where(user_id: user_id, has_read: false).order(created: :desc)
    end

    def self.clear(notification_id, user_id)
        params = {user_id: user_id, has_read: false}
        params[:id] = notification_id if notification_id != nil
        relation = self.where(params)
        return false if relation.blank?
        relation.update_all(has_read: true)
        return true
    end

    def self.clearAll(user_id)
        return self.clear(nil, user_id)
    end

end
