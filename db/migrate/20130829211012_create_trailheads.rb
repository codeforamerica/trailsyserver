class CreateTrailheads < ActiveRecord::Migration
  def change
    create_table :trailheads do |t|
      t.string :name
      t.string :source
      t.string :trail1
      t.string :trail2
      t.string :trail3
      t.point :geom, :geographic => true

      t.timestamps
    end
  end
end
