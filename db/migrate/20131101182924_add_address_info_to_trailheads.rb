class AddAddressInfoToTrailheads < ActiveRecord::Migration
  def change
    add_column :trailheads, :address, :string
    add_column :trailheads, :city, :string
    add_column :trailheads, :state, :string
    add_column :trailheads, :zip, :string
  end
end
