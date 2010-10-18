class AddPillToMessages < ActiveRecord::Migration
  def self.up
    add_column "messages", "hit", :boolean
  end

  def self.down
    remove_column "messages", "hit"
  end
end
