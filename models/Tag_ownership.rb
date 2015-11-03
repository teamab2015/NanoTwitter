class Tag_ownership < ActiveRecord::Base
    has_many :tweets
    has_many :tags
end
