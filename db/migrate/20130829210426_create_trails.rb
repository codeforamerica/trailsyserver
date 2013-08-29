class CreateTrails < ActiveRecord::Migration
  def change
    create_table :trails do |t|
      t.string :name
      t.string :opdmd_access
      t.string :source
      t.string :steward
      t.decimal :length
      t.string :horses
      t.string :dogs
      t.string :bikes
      t.string :description
      t.string :difficulty
      t.string :hike_time
      t.string :print_map_url
      t.string :surface
      
      t.timestamps
    end
  end
end
