NanoTwitter TEAMAB
=======
Team member: Jiancheng Zhu, Alex Suk, Ben Winschel, Ethan Stein  
Dec 8, 2015

[ ![Codeship Status for teamab2015/NanoTwitter](https://codeship.com/projects/c4bba410-7f91-0133-3c3e-62195a4c75a1/status?branch=master)](https://codeship.com/projects/120618)

[![Code Climate](https://codeclimate.com/github/cheng9393/NanoTwitter/badges/gpa.svg)](https://codeclimate.com/github/cheng9393/NanoTwitter)

[Profile http://teamab2015.github.io/NanoTwitter](http://teamab2015.github.io/NanoTwitter "Profile")  

[Github https://github.com/teamab2015/NanoTwitter](https://github.com/teamab2015/NanoTwitter)

[Demo https://teamab.herokuapp.com](https://teamab.herokuapp.com "Demo")  

This a sinatra application that imitates Twitter. It has following functions:  
* view timeline
* follow/unfollow
* notification
* tweet with _@ mention_ and _# tag_
* tag view
* reply view  

![ScreenShot](http://teamab2015.github.io/NanoTwitter/images/Screen%20Shot%202015-12-07%20at%203.30.28%20AM.png)
![Screenshot](http://teamab2015.github.io/NanoTwitter/images/test.png)

Technology Description
------
Redis & resque-pool

NanoTwitter cached all the relationship ("followers-#{followee_id}" stores a set of follower_ids), all users ("user-#{user.id}" stores a JSON string of user info), timeline ("homeTimeline" stores the global timeline, "userTimeline-#{user_id}" stores the timeline of a user). The relationship and user cache is loaded at the start of NanoTwitter and updated while any action among follow, unfollow, register happens.The timeline is a first fetched from database and then loaded into redis. When a person tweet, unprocessed tweet string will be added to related timeline list. Since the all timeline cache has an expire timeout of one of two minutes, processed tweet string will show up after that expire timeout. NanoTwitter also use queue to process tweet, because tweet is very costly, as it involves write tag, mention to database, add tag and mention link to original tweet and then write it to database.

Result of loader.io test
------

| Object & Condition (maintain client load 250) | Average 	| Min 	| Max   	| Success 	| Timeout 	|
|---------------------------------------------	|---------	|-----	|-------	|---------	|---------	|
| testuser tweet u = 100, t = 500, f = 30     	| 1437    	| 24  	| 4333  	| 5054    	| 0       	|
| testuser home u = 100, t = 500, f = 30      	| 2940    	| 38  	| 9110  	| 2326    	| 0       	|
| home u = 100, t = 500, f = 30               	| 1537    	| 18  	| 4105  	| 4685    	| 0       	|
| testuser tweet u = 500, t = 500, f = 100    	| 1215    	| 19  	| 3410  	| 5996    	| 0       	|
| testuser home u = 500, t = 500, f = 100     	| 1522    	| 42  	| 4623  	| 4729    	| 0       	|
| home u = 500, t = 500, f = 100              	| 1053    	| 18  	| 3266  	| 6815    	| 0       	|
| testuser tweet u = 3000, t = 2000, f = 1000 	| 4571    	| 81  	| 10004 	| 1346    	| 52      	|
| testuser home u = 3000, t = 2000, f = 1000  	| 1584    	| 27  	| 4032  	| 4585    	| 0       	|
| home u = 3000, t = 2000, f = 1000           	| 1226    	| 15  	| 4039  	| 5941    	| 0       	|


Usage
------

require ruby 2.+  
Run rake db:reset to clear the database and reseed.  
The development database comes with a user(email=test@test.com, password=test).  

Routes (not updated)
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

API (proposed)
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
