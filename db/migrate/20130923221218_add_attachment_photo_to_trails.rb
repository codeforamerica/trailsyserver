class AddAttachmentPhotoToTrails < ActiveRecord::Migration
  def self.up
    change_table :trails do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :trails, :photo
  end
end
