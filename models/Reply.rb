class Reply < ActiveRecord::Base
    belongs_to :tweets

    def self.check_index(reply_index)
        return /^\d+(-\d+)*$/.match(reply_index) != nil
    end
end
