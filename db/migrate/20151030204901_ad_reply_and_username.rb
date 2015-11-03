class AdReplyAndUsername < ActiveRecord::Migration
  def change
      add_column :users, :username, :string

      create_table :notifications do |t|
          t.integer :user_id
          t.string :content
          t.boolean :has_read
          t.datetime :created
      end

      create_table :replies do |t|
          t.string :reply_index
          t.integer :tweet_id
      end

      add_index :tags, :word
      add_index :tag_ownerships, :tag_id
      add_index :tag_ownerships, :tweet_id
      add_index :mentions, :tweet_id
      add_index :mentions, :user_id
      add_index :notifications, :user_id
      add_index :notifications, :created
      add_index :replies, :reply_index
      add_index :replies, :tweet_id

  end
end
