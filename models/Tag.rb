class Tag < ActiveRecord::Base
    has_many :tag_ownerships
    has_many :tweets, through: :tag_ownerships
end
