class DropStewardFromTrails < ActiveRecord::Migration
  def change
    remove_column :trails, :steward
  end
end
