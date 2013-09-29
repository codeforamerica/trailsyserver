class Photorecord < ActiveRecord::Base
  has_attached_file :photo, :styles => { medium: "300x300>", thumb: "100x100>" }
  belongs_to :trail
  # removing this for now, because it should be run less often than every save
  # after_save :clean_nils

  def clean_nils
    Photorecord.all.each do |photorecord|
      if photorecord.trail_id.nil?
        photorecord.destroy
      end
    end
  end
end
