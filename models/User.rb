class User < ActiveRecord::Base
    has_many :tweets
    has_many :relations
    has_many :users, through: :relations
end
