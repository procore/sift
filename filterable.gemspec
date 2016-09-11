$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'filterable/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'filterable'
  s.version     = Filterable::VERSION
  s.authors     = ['Adam Hess']
  s.email       = ['adamhess1991@gmail.com']
  # s.homepage    = 'TODO'
  s.summary     = 'Summary of Filterable.'
  # s.description = 'TODO: Description of Filterable.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*',
                'MIT-LICENSE',
                'Rakefile',
                'README.md']

  s.add_dependency 'rails', '~> 5.0.0', '>= 5.0.0.1'

  s.add_development_dependency 'sqlite3'
end
