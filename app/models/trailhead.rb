class Trailhead < ActiveRecord::Base
  set_rgeo_factory_for_column(:geom, RGeo::Geographic.spherical_factory(:srid => 4326))
end
