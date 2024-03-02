require "carddav"
require "thor"
require "yaml"

class Birthdaze < Thor
  desc "generate", "Generate calendars"
  def generate
    puts "Generate calendars"
    auth(config["url"], config["username"], config["password"])
  end

  private

  def config
    config_file = "#{ENV["HOME"]}/.config/birthdaze.yaml"
    unless File.file?(config_file)
      puts "Please add a configuration file"
      return
    end
    @config ||= YAML.load_file(config_file)
  end

  def auth(url, username, password)
    config
    client = Carddav::Client.new(url, username, password)
  end
end
