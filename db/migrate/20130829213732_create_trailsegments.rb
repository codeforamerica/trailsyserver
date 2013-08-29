class CreateTrailsegments < ActiveRecord::Migration
  def change
    create_table :trailsegments do |t|
      t.decimal :length
      t.string :source
      t.string :steward
      t.line_string :geom

      t.timestamps
    end
  end
end
