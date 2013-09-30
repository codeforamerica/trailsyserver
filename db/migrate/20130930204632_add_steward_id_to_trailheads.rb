class AddStewardIdToTrailheads < ActiveRecord::Migration
  def change
    add_column :trailheads, :steward_id, :integer
  end
end
