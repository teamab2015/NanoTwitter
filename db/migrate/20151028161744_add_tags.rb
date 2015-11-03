class AddTags < ActiveRecord::Migration
  def change
      create_table :tags do |t|
          t.string :word
      end

      create_table :tag_ownerships do |t|
          t.integer :tag_id
          t.integer :tweet_id
      end

      create_table :mentions do |t|
          t.integer :tweet_id
          t.integer :user_id
      end
  end

end
