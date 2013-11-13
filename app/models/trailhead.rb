class Trailhead < ActiveRecord::Base
  set_rgeo_factory_for_column(:geom, RGeo::Geographic.spherical_factory(:srid => 4326))

  validates :name, presence: true
  validates :source, presence: true
  validates :steward, presence: true
  validates :trail1, presence: true

  belongs_to :steward, class_name: 'Organization', foreign_key: "steward_id"
  belongs_to :source, class_name: 'Organization', foreign_key: "source_id"

  # checking to make sure this isn't a trail segment file
  validates :length, absence: true

  def self.parse_geojson(file)
    if file.class == ActionDispatch::Http::UploadedFile
      feature_collection = RGeo::GeoJSON.decode(File.read(file.path), json_parser: :json)
    elsif file.class == String
      feature_collection = RGeo::GeoJSON.decode(File.new(file), json_parser: :json)
    elsif file.class == File
      feature_collection = RGeo::GeoJSON.decode(file, json_parser: :json)
    end
    parsed_trailheads = []
    feature_collection.each do |feature|
      new_trailhead = Trailhead.new
      feature.properties.each do |property|
        key = property[0].downcase
        value = property[1]
        next if key == "id"
        unless value.nil?
          if value.to_s.downcase == "yes" || value == "Y"
            value = "y"
          end
          if value.to_s.downcase == "no" || value == "N"
            value = "n"
          end
        end
        if new_trailhead.attributes.has_key? key
          new_trailhead[key] = value
        elsif key == "source"
          new_trailhead.source = Organization.find_by code: value
        elsif key == "steward"
          new_trailhead.steward = Organization.find_by code: value
        end
      end
      new_trailhead["geom"] = feature.geometry
      if new_trailhead.steward.nil?
        new_trailhead.steward = new_trailhead.source
      end
      parsed_trailheads.push new_trailhead
    end
    parsed_trailheads
  end

  def self.parse_shapefile(file)
    shapefile_parts = []
    shapefile_directory = "#{Rails.root.to_s}/tmp/#{file.original_filename}"
    Zip::File.open(file.path) do |zip|
      zip.each do |entry|
        shapefile_parts.push(entry.name)
        FileUtils.mkdir_p(shapefile_directory)
        filename =  "#{shapefile_directory}/#{entry.name}"
        zip.extract(entry, filename) { true }
      end
    end
    shp_name = shapefile_parts[shapefile_parts.index { |name| name =~ /.shp$/}]
    json_name = shp_name.sub(/.shp$/, ".4326.geojson")

    shp_path = "#{shapefile_directory}/#{shp_name}"
    json_path = "#{shapefile_directory}/#{json_name}"
    File.delete(json_path) if FileTest.exist?(json_path)
    prj_path = shp_path.sub(/.shp$/, ".prj")
    # hack here because MPSSC shapefiles don't include projections
    s_srs_string = FileTest.exist?(prj_path) ? "" : "-s_srs EPSG:3734"

    cmd = %Q(#{ENV['GDAL_BINDIR']}/ogr2ogr -f "GeoJSON" \
             -t_srs EPSG:4326 \
             #{s_srs_string} \
             #{json_path} \
             #{shp_path})
    logger.info `#{cmd}`
    return self.parse_geojson(File.new("#{json_path}", "r"))
  end

  def self.parse(file)
    if (file.original_filename =~ /zip$/)
      return self.parse_shapefile(file)
    elsif (file.original_filename =~ /json$/)
      return self.parse_geojson(file)
    end
  end

  # def self.source_trailheads(trailheads, source) 
  #   trailheads.select { |trailhead| trailhead.source.code == source }
  # end

  # def self.non_source_trailheads(trailheads, source) 
  #   trailheads.select { |trailhead| trailhead.source.code != source }
  # end

  def distance=(dist)
    @distance = dist
  end

  def distance
    @distance
  end

  def length=(len)
    write_attribute(:length, len)
  end

  def length
    read_attribute(:length)
  end

end
