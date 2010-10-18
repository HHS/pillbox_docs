class AddDescriptionToPills < ActiveRecord::Migration
  def self.up
    add_column :pills, :description, :string
  end

  def self.down
    remove_column :pills, :description
  end
end
