# Birthdaze

[View on RubyGems](https://rubygems.org/gems/birthdaze)

Birthdaze is a tool to generate a calendar of your contacts’ birthdays
from a CardDAV server account.

## Installation

```bash
gem install ruby
```

Note Birthdaze relies on the `curb` gem, which requires `libcurl4-openssl-dev` to be installed.

## Setup

You’ll need a config file in the `~/.config/birthdaze.yaml` that looks like the below:

```yaml
username: <username>
password: <password>
url: <url>
ical_output: <path to output file>
```

## Usage

Print a list of all birthdays.
```bash
birthdaze list
```

Generate an iCalendar file of your contacts’ birthdays.
```bash
birthdaze generate
```

## Notes

- If a contact has a birthdate, the birthday will be set as recurring from that year. Otherwise,
  it will be set as recurring from the current year.

