class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :messages, [:messaging_user_id, :created_at]
    add_index :messages, [:defending_user_id, :created_at]
    add_index :users, :facebook_id
  end

  def self.down
    remove_index :messages, [:messaging_user_id, :created_at]
    remove_index :messages, [:defending_user_id, :created_at]
    remove_index :users, :facebook_id
  end
end
