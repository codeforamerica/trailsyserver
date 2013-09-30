class AddSourceIdToTrailsegments < ActiveRecord::Migration
  def change
    add_column :trailsegments, :source_id, :integer
  end
end
