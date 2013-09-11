class CreateTrailsegments < ActiveRecord::Migration
  def change
    create_table :trailsegments do |t|
      t.string :steward
      t.decimal :length
      t.string :source
 
      t.multi_line_string :geom, limit: {srid: 4326}
      t.string :trail1
      t.string :trail2
      t.string :trail3
      t.string :trail4
      t.string :trail5
      t.string :trail6
      
      t.timestamps
    end
  end
end
