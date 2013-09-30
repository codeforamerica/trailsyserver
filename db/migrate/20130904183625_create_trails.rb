class CreateTrails < ActiveRecord::Migration
  def change
    create_table :trails do |t|
      t.string :name
      t.integer :source_id
      t.integer :steward_id
      t.decimal :length
      t.string :accessible
      t.string :roadbike
      t.string :hike
      t.string :mtnbike
      t.string :equestrian
      t.string :xcntryski
      t.string :conditions
      t.string :trlsurface
      t.string :map_url
      t.string :dogs
      t.text :description
      # app-only, not in data spec
      t.integer :status, default: 0
      t.string :statustext
      t.timestamps
    end
  end
end
