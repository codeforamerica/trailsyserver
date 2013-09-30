class Trail < ActiveRecord::Base

  # has_attached_file :photo, :styles => { medium: "300x300>", thumb: "100x100>" }
  attr_accessor :delete_photo

  validates :name, uniqueness: { scope: :source, message: " has already been taken for this source"}
  validates :source, presence: true
  validates :steward, presence: true
  has_one :photorecord, dependent: :nullify

  belongs_to :steward, class_name: 'Organization', foreign_key: "steward_id"
  belongs_to :source, class_name: 'Organization', foreign_key: "source_id"

  accepts_nested_attributes_for :photorecord


  def self.parse_csv(file)
    logger.info "parse_csv"
    parsed_trails = []
    CSV.foreach(file.path, headers: true) do |row|
      new_trail = Trail.new
      next if (row.to_s =~ /^source/)
      row.headers.each do |header|
        next if header == "id"
        if new_trail.attributes.has_key? header
          new_trail[header] = row[header]
        elsif header == "source"
          new_trail.source = Organization.find_by code: row[header]
        elsif header == "steward"
          new_trail.steward = Organization.find_by code: row[header]
        end
      end
      parsed_trails.push new_trail
    end
    parsed_trails
  end

 

  def self.parse(file)
    if (file.original_filename =~ /csv$/)
      return self.parse_csv(file)
    else
      nil
    end
  end
  
  def self.source_trails(trails, source)
    logger.info("source_trails: #{trails}, #{source}")
    trails.select { |trail| trail.source.code == source }
  end

  def self.non_source_trails(trails, source) 
    trails.select { |trail| trail.source.code != source }
  end
end
