NanoTwitter TEAMAB
=======
[ ![Codeship Status for cheng9393/NanoTwitter](https://codeship.com/projects/202aa180-5fb8-0133-eeaa-4e587625a674/status?branch=master)](https://codeship.com/projects/111898)

[![Code Climate](https://codeclimate.com/github/cheng9393/NanoTwitter/badges/gpa.svg)](https://codeclimate.com/github/cheng9393/NanoTwitter)

[Github https://github.com/teamab2015/NanoTwitter](https://github.com/teamab2015/NanoTwitter)

[Demo https://teamab.herokuapp.com](https://teamab.herokuapp.com "Demo")  

This a sinatra application that imitates Twitter. It has following functions:
1. view timeline
2. follow/unfollow
3. notification
5. tweet with _@ mention_ and _# tag_
6. tag view
7. reply view  

NanoTwitter cached all the relationship ("followers-#{followee_id}" stores a set of follower_ids), all users ("user-#{user.id}" stores a JSON string of user info), timeline ("homeTimeline" stores the global timeline, "userTimeline-#{user_id}" stores the timeline of a user). The relationship and user cache is loaded at the start of NanoTwitter and updated while any action among follow, unfollow, register happens.The timeline is a first fetched from database and then loaded into redis. When a person tweet, unprocessed tweet string will be added to related timeline list. Since the all timeline cache has an expire timeout of one of two minutes, processed tweet string will show up after that expire timeout. NanoTwitter also use queue to process tweet, because tweet is very costly, as it involves write tag, mention to database, add tag and mention link to original tweet and then write it to database.

For test record, check loadtest.txt

require ruby 2.+  
Run rake db:reset to clear the database and reseed.  
The development database comes with a user(email=test@test.com, password=test).  

Routes
------
`/`  
If not logged in, then display top 50 tweets of all users, else redirect to `/user/:logged_in_user_id`

`/user/:id`  
The home page of user, displaying Top 50 tweets of followed users and himself

`/login/:id`  
log in the user with user_id, may accept requests with password parameter to log in

`/logout`  
log out the current user, after logging out redirect to `/`

`/user/register`  
display register page

`/login`  
display the login page, after logging in redirect to `/user/:id`

`/test/reset`  
delete all rows containing test user in relations table, delete all tweets send by test users, delete all test users

`/test/seed/:n`  
create n fake users

`/test/tweets/:n`  
user “testuser” generates n new fake tweets

`/test/follow/:n`  
randomly select n users to follow user “testuser”

`/test/users`  
diaplay all the fake users

API
---

**GET `v1/users/:id`**  
Get the user of given id   
result:
```
{
    name: text,
    email: text,
    id: integer,
    avatar: text
}
```

**POST `v1/users`**  
Create a user  
parameters:
```
name: text, email: text, id: integer, avatar: text
```

**GET `v1/tweets/:id`**
Get the tweet of given id  
result:
```
{
    id: integer,
    content: text,
    created: datetime,
    sender_id: integer,
    (optional)user: {
        name: text,
        email: text,
        id: integer,
        avatar: text
        }
}
```

**POST `v1/users/:id/tweets`**  
*authentication: true*  
Create a tweet for a user  
parameters:
```
id: integer, content: text
```

**GET `v1/tweets/?sort=[+-{field_name}]&page={#}&per_page={#}&embeded=[{field_name}]`**  
Search for tweets
result:
```
[{
    id: integer,
    content: text,
    created: datetime,
    sender_id: integer,
    (optional)user: {
        name: text,
        email: text,
        id: integer,
        avatar: text
        }
}]
```

**GET `v1/users/:id/tweets?sort=[+-{field_name}]&page={#}&per_page={#}&embeded=[{field_name}]`**  
Search the tweets send by a user  
result:
```
[{
    id: integer,
    content: text,
    created: datetime,
    sender_id: integer,
}]
```

**GET `v1/users/:id/followees?embeded=[{field_name}]`**  
Get the followees of a user  
result:
```
[{followee_id:integer}]
```
or
```
[{name: text,
    email: text,
    id: integer,
    avatar: text
}]
```

**GET `v1/users/:id/followers?embeded=[{field_name}]`**  
Get the followees of a user  
result:
```
[{follower_id:integer}]
```
or
```
[{
    name: text,
    email: text,
    id: integer,
    avatar: text
}]
```

**POST `/users/:id/follow?followee={followee_id}`**  
*authentication: true*  
Create relation that the user(with id) follows another(with followee_id)  

**POST `/users/:id/unfollow?followee={followee_id}`**  
*authentication: true*  
Delete relation that the user(with id) follows another(with followee_id)


![ScreenShot](https://github.com/teamab2015/NanoTwitter/blob/master/images/Screen%20Shot%202015-12-07%20at%203.30.28%20AM.png)
