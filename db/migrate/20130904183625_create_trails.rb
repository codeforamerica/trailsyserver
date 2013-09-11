class CreateTrails < ActiveRecord::Migration
  def change
    create_table :trails do |t|
      t.string :name
      t.string :opdmd_access
      t.string :source
      t.string :steward
      t.decimal :length
      t.string :opdmd
      t.string :equestrian
      t.string :xcntryski
      t.string :trlsurface
      t.string :dogs
      t.string :hike
      t.string :roadbike
      t.text :description
      t.string :difficulty
      t.string :hike_time
      t.string :map_url
      t.string :surface
      t.string :designatio
      t.timestamps
    end
  end
end
