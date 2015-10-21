NanoTwitter TEAMAB
=======

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
