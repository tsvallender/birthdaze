require "carddav"
require "digest"
require "icalendar"
require "thor"
require "yaml"

class Birthdaze < Thor
  desc "generate", "Generate calendars"
  def generate
    puts "Writing ical file to #{config['ical_output']}"
    File.open(config["ical_output"], 'w') { |file| file.write(calendar.to_ical) }
  end

  desc "list", "List birthdays"
  def list
    bdays = birthdays.sort do |a, b|
      a[:month] == b[:month] ? a[:day] <=> b[:day] : a[:month] <=> b[:month]
    end
    bdays.each { |d| puts "🎂 #{d[:day]}/#{d[:month]} - #{d[:name]}" }
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
      if name && birthday
        @birthdays << {
          name: name,
          month: month_of(birthday),
          day: day_of(birthday),
          birth_year: birth_year_of(birthday)
        }
      end
    end
    @birthdays
  end

  def calendar
    return @calendar if defined? @calendar

    @calendar = Icalendar::Calendar.new
    birthdays.each do |birthday|
      event = Icalendar::Event.new
      event.uid = uid(birthday)
      event.dtstart = Icalendar::Values::Date.new(start_date(birthday))
      event.dtend = Icalendar::Values::Date.new(end_date(birthday))
      event.summary = summary(birthday)
      event.description = description(birthday)
      event.rrule = "FREQ=YEARLY;"
      event.alarm do |alarm|
        alarm.action = "DISPLAY"
        alarm.description = "It is #{birthday[:name]}’s birthday on #{birthday[:day]}/#{birthday[:month]}"
        alarm.summary = "Birthday reminder: #{birthday[:name]}"
        alarm.trigger = "-P#{config['days_warning']}D"
      end if config["days_warning"]
      @calendar.add_event(event)
    end
    @calendar.publish
  end

  # Takes a birthday string, with or without a year, and returns a start date
  def start_date(birthday)
    year = birthday[:birth_year] || Date.today.year
    "#{year}#{birthday[:month]}#{birthday[:day]}"
  end

  def end_date(birthday)
    date = Date.parse(start_date(birthday)).next_day
    date.strftime("%Y%m%d")
  end

  # Format a deterministic UID for the event so it isn’t re-added every time the calendar is re-generated
  def uid(birthday)
    uid = Digest::SHA2.hexdigest("#{birthday[:name]}#{birthday[:day]}#{birthday[:month]}")[0..35]
    uid[8] = uid[13] = uid[18] = uid[23] = '-'
    uid
  end

  def summary(birthday)
    "🎂 #{birthday[:name]}’s birthday"
  end

  def description(birthday)
    return "" unless birthday[:birth_year]

    "#{birthday[:name]} was born in #{birthday[:birth_year]}"
  end

  def birthday_regex
    # We need the dash for dates which don’t specify a year
    /.*BDAY.*:([\d-]*).*/
  end

  def name_regex
    /FN.*:(.*)/
  end

  def month_of(date)
    date.tr("-", "")[-4..-3]
  end

  def day_of(date)
    date.tr("-", "")[-2..-1]
  end

  def birth_year_of(date)
    return nil if date.length < 8

    birth_year = date[0..3]
    return nil if birth_year == "1604" # This is set by some apps for birth dates without a year
    birth_year
  end
end
