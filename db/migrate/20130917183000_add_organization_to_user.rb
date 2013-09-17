class AddOrganizationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :organization, :string, :default => false, :null => false
  end

  def self.down
    remove_column :users, :organization
  end
end
