class Photorecord < ActiveRecord::Base
  has_attached_file :photo, :styles => { medium: "384", thumb: "100x100>" }
  belongs_to :trail
  # removing this for now, because it should be run less often than every save
  # after_save :clean_nils
  belongs_to :source, class_name: 'Organization', foreign_key: "source_id"

  def clean_nils
    Photorecord.all.each do |photorecord|
      if photorecord.trail_id.nil?
        photorecord.destroy
      end
    end
  end
end
