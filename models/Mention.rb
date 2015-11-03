class Mention < ActiveRecord::Base
    has_many :tweets
    has_many :users
end
