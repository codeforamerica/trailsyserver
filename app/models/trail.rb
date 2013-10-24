class Trail < ActiveRecord::Base

  attr_accessor :delete_photo

  validates :name, uniqueness: { scope: :source, message: " has already been taken for this source"}
  validates :source, presence: true
  validates :steward, presence: true
  has_one :photorecord, dependent: :nullify

  belongs_to :steward, class_name: 'Organization', foreign_key: "steward_id"
  belongs_to :source, class_name: 'Organization', foreign_key: "source_id"

  accepts_nested_attributes_for :photorecord, allow_destroy: true


  def self.parse_csv(file)
    parsed_trails = []
    if file.class == ActionDispatch::Http::UploadedFile
      file_ident = file.path
    else
      file_ident = file
    end
    CSV.foreach(file_ident, headers: true) do |row|
      new_trail = Trail.new
      next if (row.to_s =~ /^source/)
      row.headers.each do |header|
        next if header == "id"
        # next if header == "source"
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

  def self.parse_json(file)
    parsed_trails = []
    if file.class == ActionDispatch::Http::UploadedFile
      trails_input = JSON.parse(file.read)
    else
      trails_input = JSON.parse(File.new(file).readlines.join("\n"))
    end
    trails_input["features"].each do |feature|
      new_trail = Trail.new
      properties = feature["properties"]
      properties.each do |fieldname, fieldvalue|
        next if fieldname == "id"
        # next if fieldname == "source"
        if new_trail.attributes.has_key? fieldname
          new_trail[fieldname] = fieldvalue
        elsif fieldname == 'source'
         new_trail.source = Organization.find_by code: fieldvalue
        elsif fieldname == 'steward'
          new_trail.steward = Organization.find_by code: fieldvalue
        end
      end
      parsed_trails.push new_trail
    end
    parsed_trails
  end

  def self.parse(file)
    if (file.original_filename =~ /csv$/)
      return self.parse_csv(file)
    elsif (file.original_filename =~ /json$/)
      return self.parse_json(file)
    else
      nil
    end
  end
  
end
