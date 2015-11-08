class AddIsreply < ActiveRecord::Migration
  def change
      add_column :tweets, :is_reply, :boolean
  end
end
