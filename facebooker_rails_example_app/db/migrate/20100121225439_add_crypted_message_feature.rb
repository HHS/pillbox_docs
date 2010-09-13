class AddCryptedMessageFeature < ActiveRecord::Migration
  def self.up
    add_column :messages, :cleartext, :string, :default=>""
    add_column :messages, :crypted, :string, :default=>""
  end

  def self.down
    remove_column :messages, :cleartext
    remove_column :messages, :crypted
    
  end
end
