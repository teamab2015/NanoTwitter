# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151030204901) do

  create_table "mentions", force: :cascade do |t|
    t.integer "tweet_id"
    t.integer "user_id"
  end

  add_index "mentions", ["tweet_id"], name: "index_mentions_on_tweet_id"
  add_index "mentions", ["user_id"], name: "index_mentions_on_user_id"

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "content"
    t.boolean  "has_read"
    t.datetime "created"
  end

  add_index "notifications", ["created"], name: "index_notifications_on_created"
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id"

  create_table "relations", force: :cascade do |t|
    t.integer "followee_id"
    t.integer "follower_id"
  end

  add_index "relations", ["followee_id"], name: "index_relations_on_followee_id"
  add_index "relations", ["follower_id"], name: "index_relations_on_follower_id"

  create_table "replies", force: :cascade do |t|
    t.string  "reply_index"
    t.integer "tweet_id"
  end

  add_index "replies", ["reply_index"], name: "index_replies_on_reply_index"
  add_index "replies", ["tweet_id"], name: "index_replies_on_tweet_id"

  create_table "tag_ownerships", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "tweet_id"
  end

  add_index "tag_ownerships", ["tag_id"], name: "index_tag_ownerships_on_tag_id"
  add_index "tag_ownerships", ["tweet_id"], name: "index_tag_ownerships_on_tweet_id"

  create_table "tags", force: :cascade do |t|
    t.string "word"
  end

  add_index "tags", ["word"], name: "index_tags_on_word"

  create_table "tweets", force: :cascade do |t|
    t.text     "content"
    t.datetime "created"
    t.integer  "sender_id"
  end

  add_index "tweets", ["created"], name: "index_tweets_on_created"
  add_index "tweets", ["sender_id"], name: "index_tweets_on_sender_id"

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password"
    t.string "avatar"
    t.string "username"
  end

  add_index "users", ["email"], name: "index_users_on_email"

end
