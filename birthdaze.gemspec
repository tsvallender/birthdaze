Gem::Specification.new do |s|
  s.name        = "birthdaze"
  s.version     = "0.0.1"
  s.summary     = "Generate a birthday calendar from CardDAV"
  s.authors     = ["T S Vallender"]
  s.email       = "t@tsvallender.co.uk"
  s.homepage    = "https://git.tsvallender.co.uk/tsv/birthdaze"
  s.files       = Dir["lib/**/*", "MIT-LICENSE", "README.md"]
  s.license     = "MIT"
  s.executables << "birthdaze"
  s.add_dependency "thor"
  s.add_dependency "carddav"
end

