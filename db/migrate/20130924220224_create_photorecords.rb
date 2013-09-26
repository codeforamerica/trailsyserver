class CreatePhotorecords < ActiveRecord::Migration
  def change
    create_table :photorecords do |t|
      t.string :source
      t.string :name
      t.belongs_to :trail
      t.timestamps
    end
  end
end
