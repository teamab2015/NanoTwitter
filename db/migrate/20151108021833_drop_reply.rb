class DropReply < ActiveRecord::Migration
  def change
      drop_table :replies

      remove_column :tweets, :is_reply
      add_column :tweets, :reply_index, :string
  end
end
