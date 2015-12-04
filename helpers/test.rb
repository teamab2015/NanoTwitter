module Sinatra
  module NanoTwitter
    module TestHelper
        @@testuser_id = nil

        def testuser_id
            puts "try test user"
            if @@testuser_id.nil? then
                testuser = User.find_by(name: 'test')
                @@testuser_id = testuser.id if !testuser.nil?
            end
            @@testuser_id ||= Seeds.generateTestUser
            return @@testuser_id
        end

        def clear_testuser_id
            @@testuser_id = nil
        end

    end
  end
end
