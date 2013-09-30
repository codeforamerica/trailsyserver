class DropSourceFromTrailheads < ActiveRecord::Migration
  def change
    remove_column :trailheads, :source, :string
  end
end
