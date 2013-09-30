class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :code
      t.string :full_name
      t.string :phone
      t.string :url

      t.timestamps
    end
  end
end
