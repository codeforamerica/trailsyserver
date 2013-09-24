class Trailsegment < ActiveRecord::Base
  set_rgeo_factory_for_column(:geom, RGeo::Geographic.spherical_factory(:srid => 4326))
  validates_uniqueness_of :geom

  validates :source, presence: true
  validates :geom, presence: true

  def self.parse_geojson(file) 
    feature_collection = RGeo::GeoJSON.decode(File.read(file.path), json_parser: :json)
    parsed_trailsegments = []
    feature_collection.each do |feature|
      new_trailsegment = Trailsegment.new
      feature.properties.each do |property|
        key = property[0].downcase
        value = property[1]
        next if key == "id"
        if new_trailsegment.attributes.has_key? key
          new_trailsegment[key] = value
        end
      end
      new_trailsegment["geom"] = feature.geometry
      parsed_trailsegments.push new_trailsegment
    end
    parsed_trailsegments
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

    cmd = %Q(#{ENV['GDAL_BINDIR']}/ogr2ogr -f "GeoJSON" \
             -t_srs EPSG:4326 \
             #{json_path} \
             #{shp_path})
    logger.info cmd
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

  def self.source_trailsegments(trailsegments, source) 
    trailsegments.select { |trailsegment| trailsegment.source == source }
  end

  def self.non_source_trailsegments(trailsegments, source) 
    trailsegments.select { |trailsegment| trailsegment.source == source }
  end
end
