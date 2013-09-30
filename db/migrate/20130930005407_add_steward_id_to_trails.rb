class AddStewardIdToTrails < ActiveRecord::Migration
  def change
    add_column :trails, :steward_id, :integer
  end
end
