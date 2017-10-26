$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'filterable/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'filterable'
  s.version     = Filterable::VERSION
  s.authors     = ['Procore Technologies']
  s.email       = ['dev@procore.com']
  s.homepage    = 'https://github.com/procore/filterable'
  s.summary     = 'Summary of Filterable.'
  s.description = 'Easily write arbitrary filters'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*',
                'MIT-LICENSE',
                'Rakefile',
                'README.md']

  s.add_dependency 'rails', '> 4.2.0'

  s.add_development_dependency 'sqlite3'
end
