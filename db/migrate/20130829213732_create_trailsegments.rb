class CreateTrailsegments < ActiveRecord::Migration
  def change
    create_table :trailsegments do |t|
      t.integer :source_id
      t.integer :steward_id
      
      t.decimal :length

      t.multi_line_string :geom, geographic: true
      t.string :trail1
      t.string :trail2
      t.string :trail3
      t.string :trail4
      t.string :trail5
      t.string :trail6
      
      t.string :accessible
      t.string :roadbike
      t.string :hike
      t.string :mtnbike
      t.string :equestrian
      t.string :xcntryski
      t.string :conditions
      t.string :trlsurface
      t.string :dogs

      t.timestamps
    end
  end
end
