class AddIndex < ActiveRecord::Migration
  def change
      add_index :users, :email
      add_index :tweets, :created
      add_index :tweets, :sender_id
      add_index :relations, :followee_id
      add_index :relations, :follower_id
  end
end
