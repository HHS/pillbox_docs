class CreatePillsAndAilments < ActiveRecord::Migration
  def self.up

    create_table :pills do |t|
      t.integer :cost
      t.integer :reputation, :default=>0
      t.integer :level
      t.integer :image_id
      t.string :name
      t.string :api_ref
    end
    
    create_table :ailments do |t|
      t.references :pill
      t.references :patient
      t.string :name
    end
    
  end

  def self.down
    drop_table :pills
    drop_table :ailments
  end
end
