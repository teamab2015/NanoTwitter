class Tweet < ActiveRecord::Base
    belongs_to :users
    has_many :tag_ownerships
    has_many :mentions
    has_many :tags, through: :tag_ownerships
    has_many :users, through: :mentions
    has_many :replies
end
