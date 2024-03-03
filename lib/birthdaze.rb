require "carddav"
require "thor"
require "yaml"

class Birthdaze < Thor
  desc "generate", "Generate calendars"
  def generate
    puts "Generate calendars"
    birthdays
  end

  private

  def config(config_file = "#{ENV["HOME"]}/.config/birthdaze.yaml")
    unless File.file?(config_file)
      puts "Please add a configuration file"
      return
    end

    @config ||= YAML.load_file(config_file)
  end

  def client(url: config["url"], username: config["username"], password: config["password"])
    @client ||= Carddav::Client.new(url, username, password)
  end

  def birthdays
    birthdays = []
    client.cards.each do |card|
      card = card.parsed.to_s
      birthday = birthday_regex.match(card)[1] if birthday_regex.match?(card)
      name = name_regex.match(card)[1] if name_regex.match?(card)
      birthdays << [ name, birthday ] if name && birthday
    end
    birthdays
  end

  def birthday_regex
    # We need the dash for dates which don’t specify a year
    /.*BDAY.*:([\d-]*).*/
  end

  def name_regex
    /FN.*:(.*)/
  end
end
