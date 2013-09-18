class Trailhead < ActiveRecord::Base
  set_rgeo_factory_for_column(:geom, RGeo::Geographic.spherical_factory(:srid => 4326))

  def self.parse_geojson(file) 
    feature_collection = RGeo::GeoJSON.decode(File.read(file.path), json_parser: :json)
    parsed_trailheads = []
    feature_collection.each do |feature|
      new_trailhead = Trailhead.new
      feature.properties.each do |property|
        key = property[0]
        value = property[1]
        if new_trailhead.attributes.has_key? key
          new_trailhead[key] = value
        end
      end
      new_trailhead["geom"] = feature.geometry
      parsed_trailheads.push new_trailhead
    end
    parsed_trailheads
  end

  def self.parse(file)
    if (file.original_filename =~ /zip$/)
      return self.parse_shapefile(file)
    elsif (file.original_filename =~ /json$/)
      return self.parse_geojson(file)
    end
  end

  def self.source_trailheads(trailheads, source) 
    trailheads.select { |trailhead| trailhead.source == source }
  end

  def self.non_source_trailheads(trailheads, source) 
    trailheads.select { |trailhead| trailhead.source != source }
  end

  def distance=(dist)
    @distance = dist
  end

  def distance
    @distance
  end
end
