module TrailsHelper
  def setup_trail(trail)
    trail.build_photorecord if trail.photorecord.nil?
    trail
  end
end
