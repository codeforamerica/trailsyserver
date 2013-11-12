class Organization < ActiveRecord::Base
  has_attached_file :logo, :styles => { medium: "150x150>"}

  validates :code, uniqueness: true
  has_many :sourcetrails, class_name: "Trail", foreign_key: "source_id", dependent: :destroy
  has_many :stewardtrails, class_name: "Trail", foreign_key: "steward_id"
  has_many :users, dependent: :destroy
  has_many :sourcesegments, class_name: "Trailsegment", foreign_key: "source_id", dependent: :destroy
  has_many :stewardsegments, class_name: "Trailsegment", foreign_key: "steward_id"
  has_many :photorecords, class_name: "Photorecord", foreign_key: "source_id", dependent: :destroy
  has_many :sourcetrailheads, class_name: "Trailhead", foreign_key: "source_id", dependent: :destroy
  has_many :stewardtrailheads, class_name: "Trailhead", foreign_key: "steward_id"

  def logo_url
    @logo_url
  end

  def logo_url=(logo)
    @logo_url = logo
  end
end
