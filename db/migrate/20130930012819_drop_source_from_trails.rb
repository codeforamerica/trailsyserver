class DropSourceFromTrails < ActiveRecord::Migration
  def change
    remove_column :trails, :source
  end
end
