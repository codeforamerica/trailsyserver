class Organization < ActiveRecord::Base
  has_many :sourcetrails, class_name: "Trail", foreign_key: "source_id"
  has_many :stewardtrails, class_name: "Trail", foreign_key: "steward_id"
  # has_many :users
#   has_many :sourcesegments, class_name: "TrailSegment"
#   has_many :stewardsegments, class_name: "TrailSegment"
   has_many :photorecords, class_name: "Photorecord", foreign_key: "source_id"
   has_many :sourcetrailheads, class_name: "Trailhead", foreign_key: "source_id"
   has_many :stewardtrailheads, class_name: "Trailhead", foreign_key: "steward_id"
end
