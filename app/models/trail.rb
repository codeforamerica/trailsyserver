class Trail < ActiveRecord::Base

  def self.parse_csv(file)
    logger.info "parse_csv"
    parsed_trails = []
    CSV.foreach(file.path, headers: true) do |row|
      new_trail = Trail.new
      next if (row.to_s =~ /^source/)
      row.headers.each do |header|
        if new_trail.attributes.has_key? header
          new_trail[header] = row[header]
        end
      end
      parsed_trails.push new_trail
    end
    parsed_trails
  end

 

  def self.parse(file)
    if (file.original_filename =~ /csv$/)
      return self.parse_csv(file)
    else
      nil
    end
  end
  
  def self.source_trails(trails, source)
    trails.select { |trail| trail.source == source }
  end

  def self.non_source_trails(trails, source) 
    trails.select { |trail| trail.source != source }
  end
end
