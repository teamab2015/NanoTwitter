require_relative './test_helper.rb'

class MyUserTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_register
      User.destroy_all
      assert_raises RuntimeError do
           User.register(name: nil, username: nil, email: nil, password: nil)
      end
      assert_raises RuntimeError do
           User.register(name: "", username: nil, email: nil, password: nil)
      end
      assert_raises RuntimeError do
           User.register(name: 'hello', username: nil, email: nil, password: nil)
      end
      assert_raises RuntimeError do
           User.register(name: 'hello', username: "", email: nil, password: nil)
      end
      assert_raises RuntimeError do
           User.register(name: 'hello', username: "hello", email: nil, password: nil)
      end
      assert_raises RuntimeError do
           User.register(name: 'hello', username: "hello", email: "", password: nil)
      end
      assert_raises RuntimeError do
           User.register(name: 'hello', username: "hello", email: "hello", password: nil)
      end
      assert_raises RuntimeError do
           User.register(name: 'hello', username: "hello", email: "hello", password: "")
      end
      User.register(name: 'hello0', username: "hello1", email: "hello2", password: "hello3")
      user = User.find_by(email: "hello2")
      assert_equal(user.nil?(), false)
      assert_equal(user["name"], 'hello0')
      assert_equal(user["username"], 'hello1')
      assert_equal(user["email"], 'hello2')
      assert_equal(user["password"], 'hello3')
  end

end
