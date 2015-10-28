class User < ActiveRecord::Base
    has_many :tweets
    has_many :relations
    has_many :mentions
    has_many :users, through: :relations
    has_many :tweets, through: :mentions
end
