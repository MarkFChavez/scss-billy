require 'json'
require 'net/http'
require 'uri'


email = ARGV[0] ? ARGV[0] : "billy.nicart@gmail.com"
filename = ARGV[1] ? ARGV[1] : "styles/app.variables.scss"

URL = "http://msme.herokuapp.com/api/v1/themes?email=#{email}"

class Jarvis
  attr_reader :filename, :url

  def initialize(filename, url)
    @filename = filename
    @url = url
  end

  def process
    write_to_primary
    write_to_secondary
    write_to_tertiary
  end

  private

  def write_to_primary
    File.write(f = filename, File.read(f).gsub(/\$primary: .*/,"$primary: #{fetch_variables[:primary]};"))
  end

  def write_to_secondary
    File.write(f = filename, File.read(f).gsub(/\$secondary: .*/,"$secondary: #{fetch_variables[:secondary]};"))
  end

  def write_to_tertiary
    File.write(f = filename, File.read(f).gsub(/\$tertiary: .*/,"$tertiary: #{fetch_variables[:tertiary]};"))
  end

  def fetch_variables
    response = Net::HTTP.get_response(uri)
    result = JSON.parse(response.body).first

    {
      primary: result["primary"],
      secondary: result["secondary"],
      tertiary: result["tertiary"]
    }

  rescue => e
    { primary: "#FFF", secondary: "#FFF", tertiary: "#FFF" }
  end

  def uri
    URI.parse(url)
  end
end

# START OP
jarvis = Jarvis.new(filename, URL)
jarvis.process
puts "DONE"

