class CreatePillCategories < ActiveRecord::Migration
  def self.up
    create_table :pill_categories do |t|
      t.string :image_ref
      t.string :subheader
      t.string :description
      t.string :title
    end
    add_column :pills, :pill_category_id, :integer
    add_column :pills, :messages, :string
    
  end

  def self.down
    drop_table :pill_categories
    remove_column :pills, :pill_category_id    
    remove_column :pills, :messages    

  end
end
