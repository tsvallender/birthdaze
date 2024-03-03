require "carddav"
require "icalendar"
require "thor"
require "yaml"

class Birthdaze < Thor
  desc "generate", "Generate calendars"
  def generate
    puts "Generate calendars"
    puts calendar.inspect
  end

  desc "list", "List birthdays"
  def list
    display = birthdays.map do |name, birthday|
      {
        name: name,
        month: month_of(start_date(birthday)),
        day: day_of(start_date(birthday)),
      }
    end
    display.sort! { |a, b| a[:month] == b[:month] ? a[:day] <=> b[:day] : a[:month] <=> b[:month] }
    display.each { |d| puts "🎂 #{d[:month]}/#{d[:day]} - #{d[:name]}" }
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
    return @birthdays if defined? @birthdays

    @birthdays = []
    client.cards.each do |card|
      card = card.parsed.to_s
      birthday = birthday_regex.match(card)[1] if birthday_regex.match?(card)
      name = name_regex.match(card)[1] if name_regex.match?(card)
      @birthdays << [ name, birthday ] if name && birthday
    end
    @birthdays
  end

  def calendar
    return @calendar if defined? @calendar

    @calendar = Icalendar::Calendar.new
    birthdays.each do |name, birthday|
      @calendar.event do |event|
        puts name
        event.dtstart = Icalendar::Values::Date.new(start_date(birthday))
        event.dtend = Icalendar::Values::Date.new(end_date(birthday))
        event.summary = summary(name, birthday)
      end
    end
    @calendar.publish
  end

  # Takes a birthday string, with or without a year, and returns a start date
  def start_date(birthday)
    year = Date.today.year
    birthday = birthday.tr("-", "")
    birthday = birthday.gsub("1604", "") if birthday.start_with?("1604")
    if birthday.length < 8 # No year specified
      "#{year}#{birthday[0..3]}"
    else
      "#{year}#{birthday[4..7]}"
    end
  end

  def end_date(birthday)
    year = Date.today.year
    birthday = birthday.tr("-", "")
    birthday = birthday.gsub("1604", "") if birthday.start_with?("1604")
    if birthday.length < 8 # No year specified
      "#{year}#{birthday[0..1]}#{birthday[2..3].to_i + 1}"
    else
      "#{year}#{birthday[4..5]}#{birthday[6..7].to_i + 1}"
    end
  end

  def summary(name, birthday)
    return "#{name}’s birthday" if birthday.start_with?("-") || birthday.start_with?("1604")

    birth_year = birthday[0..3].to_i
    age = Date.today.year - birth_year + 1
    "🎂 #{name}’s #{age} birthday"
  end

  def set_reminders
  end

  def birthday_regex
    # We need the dash for dates which don’t specify a year
    /.*BDAY.*:([\d-]*).*/
  end

  def name_regex
    /FN.*:(.*)/
  end

  def month_of(date)
    date.length < 8 ? date[0..1] : date[4..5]
  end

  def day_of(date)
    date.length < 8 ? date[2..3] : date[6..7]
  end
end
