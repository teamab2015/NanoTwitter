require_relative '../models/User'

module Authentication

  def self.logged_in?(session, params)
      return self.get_logged_in_user_id(session, params) != nil
  end

  def self.has_user_privilege?(session, params)

  end

  def self.get_logged_in_user_id(session, params)
      return nil if session.nil? || session[:user_id].nil?
      return session[:user_id].to_i
  end

  def self.get_logged_in_user(session, params)
      logged_in_user_id = self.get_logged_in_user_id(session, params)
      return nil if logged_in_user_id.nil?
      return User.find_by(id: logged_in_user_id)
  end

end
