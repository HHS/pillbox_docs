class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :user_id
      t.integer :poster_id
      t.text :body
      t.timestamps
    end
    add_index :comments, [:user_id,:created_at]
  end

  def self.down
    drop_table :comments
    remove_index :comments, [:user_id,:created_at]
  end
end
