class ChangeToDatetime < ActiveRecord::Migration
  def change
      change_column(:tweets, :created, :datetime)
  end
end
