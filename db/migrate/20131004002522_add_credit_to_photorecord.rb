class AddCreditToPhotorecord < ActiveRecord::Migration
  def change
    add_column :photorecords, :credit, :string
  end
end
