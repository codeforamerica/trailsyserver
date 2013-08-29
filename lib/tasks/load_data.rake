require 'csv'

task :load_traildata => :environment do
  CSV.foreach(ENV["INPUT"], headers: true) do |row|

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