class DropStewardFromTrailsegments < ActiveRecord::Migration
  def change
    remove_column :trailsegments, :steward, :string
  end
end
