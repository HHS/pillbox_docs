class CreatePatients < ActiveRecord::Migration
  def self.up
    create_table :patients do |t|
      t.string :name
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :patients
  end
end
