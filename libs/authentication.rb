require_relative '../models/User'

module Authentication

  def self.logged_in?(session)
      return self.get_logged_in_user_id(session) != nil
  end

  def self.has_user_privilege?(session, user_id)
      return self.logged_in?(session) && self.get_logged_in_user_id(session) == user_id
  end

  def self.get_logged_in_user_id(session)
      return nil if session.nil? || session[:user_id].nil?
      return session[:user_id].to_i
  end

  def self.get_logged_in_user(session)
      logged_in_user_id = self.get_logged_in_user_id(session)
      return nil if logged_in_user_id.nil?
      return User.find_by(id: logged_in_user_id)
  end

end
