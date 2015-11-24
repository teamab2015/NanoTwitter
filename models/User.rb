class User < ActiveRecord::Base
    has_many :tweets
    has_many :relations
    has_many :mentions
    has_many :users, through: :relations
    has_many :tweets, through: :mentions
    has_many :notifications

    def self.register(params)
        name = params[:name]
        username = params[:username]
        email = params[:email]
        password = params[:password]
        raise 'name is not given' if name.nil? || name.class != String || name.length == 0
        raise 'username is not given' if username.nil? || username.class != String || username.length == 0
        raise 'email is not given' if email.nil? || email.class != String || email.length == 0
        raise 'password is not given' if password.nil? || password.class != String || password.length == 0
        raise 'username has already been registered' if self.find_by(username: username) != nil
        raise 'email has already been registered' if self.find_by(email: email) != nil
        user = User.create(name: name, username: username, email: email, password: password, avatar: Faker::Avatar.image)
        return if user.nil?
        NT_Cache.addUser(user)
        return user
    end
end
