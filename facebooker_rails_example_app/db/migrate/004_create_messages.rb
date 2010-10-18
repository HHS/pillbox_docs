class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :messaging_user_id
      t.integer :defending_user_id
      t.integer :pill_id

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
