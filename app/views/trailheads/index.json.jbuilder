json.array!(@trailheads) do |trailhead|
  json.extract! trailhead, :name, :source, :trail1, :trail2, :trail3, :geom
  json.url trailhead_url(trailhead, format: :json)
end
