module Sinatra
  module NanoTwitter
    module TestHelper

        def testuser_id
            testuser_id = $redis.get("testuser_id")
            testuser_id = testuser_id.to_i if testuser_id != nil
            return testuser_id if testuser_id != nil
            testuser = User.find_by(name: 'test')
            testuser_id = testuser.id if !testuser.nil?
            testuser_id ||= Seeds.generateTestUser
            $redis.set("testuser_id", testuser_id.to_s)
            return testuser_id
        end

        def clear_testuser_id
            $redis.del("testuser_id")
        end

    end
  end
end
