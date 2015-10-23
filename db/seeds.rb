require_relative "../libs/seeds"


test_user_id = Seeds.generateTestUser
Seeds.generateUsers(200)
Seeds.generateTweets
Seeds.generateRelations(followee_id: test_user_id)
Seeds.generateRelations(follower_id: test_user_id)
