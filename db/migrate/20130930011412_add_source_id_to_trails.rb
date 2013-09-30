class AddSourceIdToTrails < ActiveRecord::Migration
  def change
    add_column :trails, :source_id, :integer
  end
end
