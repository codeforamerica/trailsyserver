class CreateTrailheads < ActiveRecord::Migration
  def change
    create_table :trailheads do |t|
      t.string :name
      t.string :steward
      t.string :source
      t.string :trail1
      t.string :trail2
      t.string :trail3
      t.string :trail4
      t.string :trail5
      t.string :trail6
      t.string :parking
      t.string :water
      t.string :restrooms
      t.string :kiosk
      t.string :park
      
      t.point :geom, geographic: true

      t.timestamps
    end
  end
end
