class DropStewardFromTrailheads < ActiveRecord::Migration
  def change
    remove_column :trailheads, :steward, :string
  end
end
