require 'csv'
require 'rgeo-geojson'



namespace :load do
  task :all => [:trails, :trailheads, :segments]
  
  task :trails => :environment do
    Trail.destroy_all
    if ENV['TRAILS_INPUT']
      input_file_names = [ENV['TRAILS_INPUT']]
    else
      input_file_names = ["lib/cvnp_traildata.csv", "lib/mpssc_traildata.csv"]
    end
    input_file_names.each do |input_file_name|
      if input_file_name =~ /csv$/
        parsed_trails = Trail.parse_csv(input_file_name)
      elsif input_file_name =~ /json$/
        parsed_trails = Trail.parse_json(input_file_name)
      else
        parsed_trails = []
      end
      parsed_trails.each do |trail|
        p "#{trail.source.code}: #{trail.name}"
        if !trail.save
          p trail.errors.full_messages
        end
      end
    end
  end

  task :trailheads => :environment do
    Trailhead.destroy_all
    if ENV['TRAILHEADS_INPUT']
      input_file_names = [ENV['TRAILHEADS_INPUT']]
    else
      input_file_names = ["lib/cvnp_trailheads.geojson", "lib/mpssc_trailheads.geojson"]
    end
    input_file_names.each do |input_file_name|
      parsed_trailheads = Trailhead.parse_geojson(input_file_name)
      parsed_trailheads.each do |trailhead|
        p "#{trailhead.source.code}: #{trailhead.name}"
        if !trailhead.save
          p trailhead.errors.full_messages
        end
      end
    end
  end
  

  task :segments => :environment do
    Trailsegment.destroy_all
    if ENV['SEGMENTS_INPUT']
      input_file_names = [ENV['SEGMENTS_INPUT']]
    else
      input_file_names = ["lib/cvnp_segments.geojson", "lib/mpssc_segments.geojson"]
    end
    input_file_names.each do |input_file_name|
      parsed_segments = Trailsegment.parse_geojson(input_file_name)
      parsed_segments.each do |segment|
        p "#{segment.source.code}: segment added."
        if !segment.save
          p segment.errors.full_messages
        end
      end
    end
  end

 
end
