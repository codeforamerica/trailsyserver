class DropSourceFromTrailsegments < ActiveRecord::Migration
  def change
    remove_column :trailsegments, :source, :string
  end
end
