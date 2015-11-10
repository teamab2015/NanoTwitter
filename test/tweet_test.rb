require_relative './test_helper.rb'

class MyTweetTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_tweet
      User.destroy_all
      Tweet.destroy_all
      user1_id = User.register(name: 'user1', username: 'user1', email: 'user1', password: 'user1').id
      user2_id = User.register(name: 'user2', username: 'user2', email: 'user2', password: 'user2').id
      user3_id = User.register(name: 'user3', username: 'user3', email: 'user3', password: 'user3').id
      Relation.add({follower_id: user1_id, followee_id: user2_id})
      Tweet.add(user3_id, "test tweet 5", nil)
      Tweet.add(user1_id, "test tweet 1", nil)
      Tweet.add(user2_id, "test tweet 2", nil)
      Tweet.add(user3_id, "test tweet 6", nil)
      Tweet.add(user2_id, "test tweet 3", nil)
      timeline1 = Tweet.getTimeline(user_id: user1_id)
      timeline2 = Tweet.getTimeline(user_id: user2_id)
      assert_equal(timeline1.length, 3)
      assert_equal(timeline2.length, 2)
      assert_equal(timeline1[0]["content"], "test tweet 3")
      assert_equal(timeline1[1]["content"], "test tweet 2")
      assert_equal(timeline1[2]["content"], "test tweet 1")
      assert_equal(timeline2[0]["content"], "test tweet 3")
      assert_equal(timeline2[1]["content"], "test tweet 2")
      timeline3 = Tweet.getTimeline({})
      assert_equal(timeline3.length, 5)
      assert_equal(timeline3[0]["content"], "test tweet 3")
      assert_equal(timeline3[1]["content"], "test tweet 6")
      assert_equal(timeline3[2]["content"], "test tweet 2")
      assert_equal(timeline3[3]["content"], "test tweet 1")
      assert_equal(timeline3[4]["content"], "test tweet 5")
  end

end
