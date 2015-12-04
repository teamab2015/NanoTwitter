require_relative './nanotwitter.rb'
require "minitest/autorun"

class TestClientlib < Minitest::Test
  def setup
    @global_timeline = NanoTwitter.getTimeline(nil)
  end

  def test_get_global_timeline
      assert @global_timeline != nil
  end

  def test_get_user_timeline
      return if @global_timeline.length == 0
      user_id = @global_timeline[0]["sender_id"]
      assert NanoTwitter.getTimeline(user_id) != nil
  end

  def test_get_user_info
      return if @global_timeline.length == 0
      user_id = @global_timeline[0]["sender_id"]
      assert NanoTwitter.getUser(user_id) != nil
  end

  def test_get_tweet_info
      return if @global_timeline.length == 0
      tweet_id = @global_timeline[0]["id"]
      assert NanoTwitter.getTweet(tweet_id) != nil
  end

  def test_conformity
      return if @global_timeline.length == 0
      @global_timeline.sample(3).each do |original_tweet|
          user_id = original_tweet["sender_id"]
          tweet_id = original_tweet["id"]
          user_info = NanoTwitter.getUser(user_id)
          tweet_info = NanoTwitter.getTweet(tweet_id)
          assert user_info["name"] == original_tweet["name"], "name not equal"
          assert user_info["email"] == original_tweet["email"], "email not equal"
          assert tweet_info["content"] == original_tweet["content"], "content not equal"
      end
  end

end
