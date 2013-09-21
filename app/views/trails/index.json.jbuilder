# this isn't used at the moment--RGeo's GeoJSON is used instead

json.array!(@trails) do |trail|
  json.extract! trail, :name, :opdmd_access, :source, :steward, :length, :horses, :dogs, :bikes, :description, :difficulty, :hike_time, :print_map_url, :surface
  json.url trail_url(trail, format: :json)
end
