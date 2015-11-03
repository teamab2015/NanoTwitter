require_relative './test_helper.rb'

class MyRelationTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_tweet
      User.destroy_all
      Tweet.destroy_all
      user1_id = User.register(name: 'user1', username: 'user1', email: 'user1', password: 'user1').id
      user2_id = User.register(name: 'user2', username: 'user2', email: 'user2', password: 'user2').id
      assert_equal(Relation.exist?({follower_id: user1_id, followee_id: user2_id}), false)
      Relation.add({follower_id: user1_id, followee_id: user2_id})
      assert_equal(Relation.exist?({follower_id: user1_id, followee_id: user2_id}), true)
      assert_equal(Relation.exist?({follower_id: user2_id, followee_id: user1_id}), false)
  end

end
