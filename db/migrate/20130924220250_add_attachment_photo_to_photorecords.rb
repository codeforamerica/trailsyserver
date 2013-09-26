class AddAttachmentPhotoToPhotorecords < ActiveRecord::Migration
  def self.up
    add_attachment :photorecords, :photo
  end

  def self.down
    remove_attachment :photorecord, :photo
  end
end
