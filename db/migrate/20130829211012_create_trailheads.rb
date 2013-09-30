class CreateTrailheads < ActiveRecord::Migration
  def change
    create_table :trailheads do |t|
      t.string :name
      t.integer :steward_id
      t.integer :source_id
      t.string :trail1
      t.string :trail2
      t.string :trail3
      t.string :trail4
      t.string :trail5
      t.string :trail6
      t.string :parking
      t.string :drinkwater
      t.string :restrooms
      t.string :kiosk
      t.string :parking
      t.string :contactnum
      t.point :geom, geographic: true

      t.timestamps
    end
  end
end
