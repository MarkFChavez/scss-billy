require 'json'
require 'net/http'
require 'uri'

DEFAULT_EMAIL = "billy.nicart@gmail.com"
DEFAULT_FILENAME = "styles/app.variables.scss"

email = ARGV[0] ? ARGV[0] : DEFAULT_EMAIL
filename = ARGV[1] ? ARGV[1] : DEFAULT_FILENAME
endpoint = "http://msme.herokuapp.com/api/v1/themes?email=#{email}"

class Jarvis
  attr_reader :filename, :url

  def initialize(filename, url)
    @filename = filename
    @url = url
  end

  def process!
    modify_primary_var!
    modify_secondary_var!
    modify_tertiary_var!
  end

  private

  def modify_primary_var!
    File.write(f = filename, File.read(f).gsub(/\$primary: .*/,"$primary: #{fetch_variables![:primary]};"))
  end

  def modify_secondary_var!
    File.write(f = filename, File.read(f).gsub(/\$secondary: .*/,"$secondary: #{fetch_variables![:secondary]};"))
  end

  def modify_tertiary_var!
    File.write(f = filename, File.read(f).gsub(/\$tertiary: .*/,"$tertiary: #{fetch_variables![:tertiary]};"))
  end

  def fetch_variables!
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
jarvis = Jarvis.new(filename, endpoint)
jarvis.process!
puts "DONE"

