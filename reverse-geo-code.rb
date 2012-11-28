#!/usr/bin/ruby -w
require 'csv'
require 'bundler'
Bundler.require

input_file_name  = ARGV[0] || "lat_long.csv"
output_file_name = ARGV[1] || "lat_long_reverse_coded.csv"

header = "place_id|line4| line3| line2| line1| offsetlat| county| house| offsetlon| countrycode| postal| longitude| state| street| country| latitude| cross| radius| quality| city| neighborhood"
File.open(output_file_name, 'w') { |f| f.write("#{header}\n") }

CSV.foreach(input_file_name) do |row|
  latitude  = row[0]
  longitude = row[1]
  place_id  = row[2]
  response  = Faraday.get "http://where.yahooapis.com/geocode?q=#{latitude},#{longitude}&gflags=AR&flags=J&appid=#{ENV['app_id']}"
  json_response    =  JSON.parse(response.body)["ResultSet"]

  if json_response["Found"] > 0
    result = json_response["Results"].first
    csv ="#{place_id}|#{result['line4']}| #{result['line3']}| #{result['line2']}| #{result['line1']}| #{result['offsetlat']}| #{result['county']}| #{result['house']}| #{result['offsetlon']}| #{result['countrycode']}| #{result['postal']}| #{result['longitude']}| #{result['state']}| #{result['street']}| #{result['country']}| #{result['latitude']}| #{result['cross']}| #{result['radius']}| #{result['quality']}| #{result['city']}| #{result['neighborhood']}" 
    File.open(output_file_name, 'a') { |f| f.write("#{csv}\n") }
  else
    p json_response.merge( {:latitude => latitude, :longitude => longitude})
  end
end
