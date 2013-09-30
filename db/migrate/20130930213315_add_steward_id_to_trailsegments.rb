class AddStewardIdToTrailsegments < ActiveRecord::Migration
  def change
    add_column :trailsegments, :steward_id, :integer
  end
end
