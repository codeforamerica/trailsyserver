class CreatePhotorecords < ActiveRecord::Migration
  def change
    create_table :photorecords do |t|
      t.integer :source_id
      t.string :name
      t.belongs_to :trail
      t.timestamps
    end
  end
end
