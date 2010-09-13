class AddAcceptedNamesAndProdcodesToPills < ActiveRecord::Migration
  def self.up
    add_column :pills, :prodcode, :string
    add_column :pills, :accepted_names, :string
  end

  def self.down
    remove_column :pills, :accepted_names
    remove_column :pills, :prodcode
  end
end