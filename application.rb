require 'csv'
require 'bundler'
Bundler.require

get "/upload" do
   haml :upload
end

post "/upload" do
  File.open('uploads/' + params['myfile'][:filename], "w") do |f|
    f.write(params['myfile'][:tempfile].read)
  end
  @@filename = params['myfile'][:filename]
  haml :success
end

get "/reverse_geo_code_it" do
  reverse_geo_code("uploads/#{@@filename}", "uploads/#{params["output_filename"]}")
  return "done successfully"
end

def reverse_geo_code input_file_name, output_file_name
  output_file_name = output_file_name || "reverse_geo_coded_#{input_file_name}"
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
end
