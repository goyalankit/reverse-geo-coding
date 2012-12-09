#!/usr/bin/ruby
require 'csv'
require 'bundler'
Bundler.require



input_file_name  = ARGV[0] || "lat_long.csv"
output_file_name = ARGV[1] || "lat_long_reverse_coded.csv"

header = "place_id|line4| line3| line2| line1| offsetlat| county| house| offsetlon| countrycode| postal| longitude| state| street| country| latitude| cross| radius| quality| city| neighborhood"
File.open(output_file_name, 'w') { |f| f.write("#{header}\n") }

count = %x{wc -l #{input_file_name}}.split.first.to_i
puts "starting reverse geo-coding process for #{count} places\n"
pbar = ProgressBar.create(:format => '%c/%C %a |%b>>%i| %p%% %t', :starting_at => 0, :total => count, :title => "Places", :smoothing => 0.6)

CSV.foreach(input_file_name) do |row|
  latitude  = row[0]
  longitude = row[1]
  place_id  = row[2]
  response  = Faraday.get "http://where.yahooapis.com/geocode?q=#{latitude},#{longitude}&gflags=AR&flags=J&appid=#{ENV['app_id']}"
  begin
    json_response    =  JSON.parse(response.body)["ResultSet"]
  rescue
    p "error"
  end
  pbar.increment
  if json_response["Found"].to_i > 0
    result = json_response["Results"].first
    csv ="#{place_id}|#{result['line4']}| #{result['line3']}| #{result['line2']}| #{result['line1']}| #{result['offsetlat']}| #{result['county']}| #{result['house']}| #{result['offsetlon']}| #{result['countrycode']}| #{result['postal']}| #{result['longitude']}| #{result['state']}| #{result['street']}| #{result['country']}| #{result['latitude']}| #{result['cross']}| #{result['radius']}| #{result['quality']}| #{result['city']}| #{result['neighborhood']}" 
    File.open(output_file_name, 'a') { |f| f.write("#{csv}\n") }
  else
    puts "#{json_response.merge( {:latitude => latitude, :longitude => longitude})}\n"
  end
  sleep(7)
end
