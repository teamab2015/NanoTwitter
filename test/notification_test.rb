require_relative './test_helper.rb'

class MyNotificationTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_tweet
      User.destroy_all
      Notification.destroy_all
      user1_id = User.register(name: 'user1', username: 'user1', email: 'user1', password: 'user1').id
      user2_id = User.register(name: 'user2', username: 'user2', email: 'user2', password: 'user2').id
      Notification.notify(user1_id, 'c1')
      Notification.notify(user1_id, 'c2')
      Notification.notify(user2_id, 'c3')
      notifications1 = Notification.getUnread(user1_id)
      notifications2 = Notification.getUnread(user2_id)
      assert_equal(notifications1.length, 2)
      assert_equal(notifications2.length, 1)
      assert_equal(notifications1[0]["content"], "c2")
      assert_equal(notifications1[1]["content"], "c1")
      assert_equal(notifications2[0]["content"], "c3")
  end

end
