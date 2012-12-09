require 'csv'
require 'bundler'
require 'logger'
Bundler.require

class ReverseGeocode < Sinatra::Base

  get "/" do
    redirect '/upload'
  end

  get "/upload" do
     haml :upload
  end

  post "/upload" do
    @logger = Logger.new("geo_code.log")
    
    File.open('public/uploads/' + params['myfile'][:filename], "w") do |f|
      f.write(params['myfile'][:tempfile].read)
    end

    @filename         = params['myfile'][:filename]
    @output_filename = "#{@filename}_processed_#{Time.now.strftime('%Y%m%d%H')}.csv"

    child = fork do
      @logger.info("process started at #{Time.now}")
      begin
        reverse_geo_code("public/uploads/#{@filename}", "public/uploads/processed/#{@output_filename}")
      rescue StandardError => e
        @logger.error e
        @logger.error e.backtrace
      end
      @logger.info("process finished at #{Time.now}")
    end
    Process.detach(child)
    redirect '/log'
  end

  get "/log" do
    return %x{tail -5 geo_code.log}.gsub(',', '<br/>')
  end
end


def reverse_geo_code input_file_name, output_file_name
  output_file_name = output_file_name || "reverse_geo_coded_#{input_file_name}"
  header = "place_id|line4| line3| line2| line1| offsetlat| county| house| offsetlon| countrycode| postal| longitude| state| street| country| latitude| cross| radius| quality| city| neighborhood"
  File.open(output_file_name, 'w') { |f| f.write("#{header}\n") }
  count = 0
  CSV.foreach(input_file_name) do |row|
    latitude  = row[0]
    longitude = row[1]
    place_id  = row[2]
    response  = Faraday.get "http://where.yahooapis.com/geocode?q=#{latitude},#{longitude}&gflags=AR&flags=J&appid=#{ENV['app_id']}"
    begin
      json_response    =  JSON.parse(response.body)["ResultSet"]
    rescue
      next
    end

    if json_response["Found"].to_i > 0
      result = json_response["Results"].first
      csv ="#{place_id}|#{result['line4']}| #{result['line3']}| #{result['line2']}| #{result['line1']}| #{result['offsetlat']}| #{result['county']}| #{result['house']}| #{result['offsetlon']}| #{result['countrycode']}| #{result['postal']}| #{result['longitude']}| #{result['state']}| #{result['street']}| #{result['country']}| #{result['latitude']}| #{result['cross']}| #{result['radius']}| #{result['quality']}| #{result['city']}| #{result['neighborhood']}" 
      File.open(output_file_name, 'a') { |f| f.write("#{csv}\n") }
    else
      p json_response.merge( {:latitude => latitude, :longitude => longitude})
    end
  end
  output_file_name = output_file_name.sub('public','')
  @logger.info(",,<a href='#{output_file_name}'>Download file<\/a>")
  sleep(7)
end
