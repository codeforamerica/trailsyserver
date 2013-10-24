class AddParkToTrailheads < ActiveRecord::Migration
  def change
    add_column :trailheads, :park, :string
  end
end
