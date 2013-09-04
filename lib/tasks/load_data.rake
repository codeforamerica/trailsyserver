require 'csv'
require 'rgeo-geojson'

namespace :load do
  task :trails => :environment do
    CSV.foreach(ENV["TRAIL_INPUT"], headers: true) do |row|
      @trail = Trail.new
      row.headers.each do |header|
        if header.downcase == "wkt" 
          next
        else
          @trail.send "#{header.downcase.to_sym}=", row[header]
        end
      end
      @trail.source = row["source"]
      @trail.save
    end
  end

  task :trailheads => :environment do

    File.open(ENV["TRAILHEADS_INPUT"]) do |geojson|
      feature_collection = RGeo::GeoJSON.decode(geojson, { geo_factory: RGeo::Geographic.spherical_factory(:srid => 4326), json_parser: :json})
      feature_collection.each do |feature|
        @trailhead = Trailhead.new
        feature.properties.each do |property|
          if property[0].downcase != 'wkt'
            @trailhead.send "#{property[0].downcase.to_sym}=", property[1]
          end
        end
        # p feature.geometry
        @trailhead.geom = feature.geometry
        @trailhead.save
      end
    end  
  end

  task :segments => :environment do
    File.open(ENV["SEGMENTS_INPUT"]) do |geojson|
      feature_collection = RGeo::GeoJSON.decode(geojson, { geo_factory: RGeo::Geographic.spherical_factory(:srid => 4326), json_parser: :json})
      feature_collection.each do |feature|
        @segment = Trailsegment.new
        feature.properties.each do |property|
          if property[0].downcase != 'wkt'
            @segment.send "#{property[0].downcase.to_sym}=", property[1]
          end
        end
        @segment.geom = feature.geometry
        if !@segment.save
          p "Duplicate!"
        end
      end
    end
  end
end
