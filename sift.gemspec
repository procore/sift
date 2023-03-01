$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "sift/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "procore-sift"
  s.version     = Sift::VERSION
  s.authors     = ["Procore Technologies"]
  s.email       = ["dev@procore.com"]
  s.homepage    = "https://github.com/procore/sift"
  s.summary     = "Summary of Sift."
  s.description = "Easily write arbitrary filters"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*",
                "MIT-LICENSE",
                "Rakefile",
                "README.md"]

  s.required_ruby_version = ">= 2.7.0"

  s.add_dependency "activerecord", ">= 6.1"
  s.add_dependency "net-http"

  s.add_development_dependency "pry"
  s.add_development_dependency "rails", ">= 7.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "rubocop", "0.71.0"
  s.add_development_dependency "sqlite3"
end
