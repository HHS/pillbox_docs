class CreatePractices < ActiveRecord::Migration
  def self.up
    create_table :practices do |t|
      t.string :name
      t.integer :level
      t.integer :next_practice_id
      t.integer :minimum_hits

      t.timestamps
    add_column "users", "practice_id", :integer
    add_column "pills", "drug_class", :integer
    end
  end

  def self.down
    drop_table :practices
    remove_column "users", "practice_id"
    remove_column "pills", "drug_class"
  end
end
