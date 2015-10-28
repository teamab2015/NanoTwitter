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

ActiveRecord::Schema.define(version: 20151028161744) do

  create_table "mentions", force: :cascade do |t|
    t.integer "tweet_id"
    t.integer "user_id"
  end

  create_table "relations", force: :cascade do |t|
    t.integer "followee_id"
    t.integer "follower_id"
  end

  add_index "relations", ["followee_id"], name: "index_relations_on_followee_id"
  add_index "relations", ["follower_id"], name: "index_relations_on_follower_id"

  create_table "tag_ownerships", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "tweet_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "word"
  end

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
  end

  add_index "users", ["email"], name: "index_users_on_email"

end
