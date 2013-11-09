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

    # if the encoding is bad, assume windows-1252
    
    contents = File.read(file_ident)
    unless contents.valid_encoding?
      contents.encode!("utf-8", "windows-1252", :invalid => :replace)
    end

    CSV.parse(contents, headers: true, header_converters: :downcase) do |row|
      new_trail = Trail.new
      next if (row.to_s =~ /^source/)

      row.headers.each do |header|
        value = row[header]
        next if header == "id"
        unless value.nil?
          if value.to_s.downcase == "yes" || value == "Y"
            value = "y"
          end
          if value.to_s.downcase == "no" || value == "N"
            value = "n"
          end
        end
        # next if header == "source"
        if new_trail.attributes.has_key? header
          new_trail[header] = value
        elsif header == "source"
          new_trail.source = Organization.find_by code: value
        elsif header == "steward"
          new_trail.steward = Organization.find_by code: value
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
        unless fieldvalue.nil?
          if fieldvalue.to_s.downcase == "yes" || fieldvalue == "Y"
            fieldvalue = "y"
          end
          if fieldvalue.to_s.downcase == "no" || fieldvalue == "N"
            fieldvalue = "n"
          end
        end
        # next if fieldname == "source"
        if new_trail.attributes.has_key? fieldname
          logger.info fieldname
          logger.info fieldvalue
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
  
  def self.to_csv
    CSV.generate do |csv|
      headers = column_names
      headers.each_index do |index|
        if headers[index] == "source_id"
          headers[index] = "source"
        end
        if headers[index] == "steward_id"
          headers[index] = "steward"
        end
      end
      csv << headers
      all.each do |trail|
        row_ary = []
        headers.each do |header|
          if header == "source"
            row_ary.push trail.source.code
          elsif header == "steward"
            row_ary.push trail.steward.code
          else
            row_ary.push trail.read_attribute("#{header}")
          end
        end
        csv << row_ary
      end
    end
  end
end
