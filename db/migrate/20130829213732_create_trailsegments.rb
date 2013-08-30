class CreateTrailsegments < ActiveRecord::Migration
  def change
    create_table :trailsegments do |t|
      t.decimal :length
      t.string :source
      t.string :steward
      t.multi_line_string :geom, limit: {srid: 4326}
      t.string :name1
      t.string :name2
      t.string :name3
      t.timestamps
    end
  end
end
