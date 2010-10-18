class AddTotalHitsToUsers < ActiveRecord::Migration
  def self.up
    add_column "users", "total_hits", :integer
  end

  def self.down
    remove_column "users", "total_hits"
  end
end
