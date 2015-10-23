class Basic < ActiveRecord::Migration
  def change
      create_table :users do |t|
          t.string :name
          t.string :email
          t.string :password
          t.string :avatar
      end

      create_table :tweets do |t|
          t.text :content
          t.date :created
          t.integer :sender_id
      end

      create_table :relations do |t|
          t.integer :followee_id
          t.integer :follower_id
      end

  end


end
