class AddSourceIdToTrailheads < ActiveRecord::Migration
  def change
    add_column :trailheads, :source_id, :integer
  end
end
