Gem::Specification.new do |s|
  s.name        = "birthdaze"
  s.version     = "0.0.1"
  s.summary     = "Generate a birthday calendar from CardDAV"
  s.authors     = ["T S Vallender"]
  s.email       = "t@tsvallender.co.uk"
  s.homepage    = "https://git.tsvallender.co.uk/tsv/birthdaze"
  s.files       = Dir["bin/*", "lib/**/*", "MIT-LICENSE", "README.md"]
  s.license     = "MIT"
  s.bindir      = "bin"
  s.executables << "birthdaze"
  s.add_dependency "carddav"
  s.add_dependency "icalendar"
  s.add_dependency "thor"
end

