require_relative './test_helper.rb'
require 'json'

class MyIntegrationTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_home
    get '/'
    assert last_response.ok?
    #assert_equal "Hello, World!", last_response.body
  end

  def test_timeline_api
      User.destroy_all
      Tweet.destroy_all
      user1_id = User.register(name: 'user1', username: 'user1', email: 'user1', password: 'user1').id
      user2_id = User.register(name: 'user2', username: 'user2', email: 'user2', password: 'user2').id
      Relation.add({follower_id: user1_id, followee_id: user2_id})
      Tweet.write(user1_id, "test tweet 1", nil, nil)
      Tweet.write(user2_id, "test tweet 2", nil, nil)
      get "/api/v1/users/#{user1_id}/tweets"
      assert last_response.ok?
      data = JSON.parse(last_response.body)
      assert_equal 2, data.length
      assert_equal "test tweet 2", data[0]["content"]
      assert_equal "test tweet 1", data[1]["content"]
      User.destroy_all
      Tweet.destroy_all
  end

end
