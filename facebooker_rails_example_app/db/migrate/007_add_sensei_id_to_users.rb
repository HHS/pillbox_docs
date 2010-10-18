class AddSenseiIdToUsers < ActiveRecord::Migration
  def self.up
    add_column "users", "sensei_id", :integer
  end

  def self.down
    remove_column "users", "sensei_id"
  end
end
