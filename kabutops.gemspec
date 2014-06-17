$:.push File.expand_path("../lib", __FILE__)

require 'kabutops/version'

Gem::Specification.new do |s|
  s.name        = 'kabutops'
  s.version     = Kabutops::VERSION
  s.date        = '2014-06-16'
  s.summary     = ''
  s.description = ''
  s.authors     = ['Rene Klacan']
  s.email       = 'rene@klacan.sk'
  s.files       = Dir["{lib}/**/*", "LICENSE", "README.md"]
  s.executables = []
  s.homepage    = 'https://github.com/reneklacan/kabutops'
  s.license     = 'Beerware'

  s.required_ruby_version = '~> 1.9'

  s.add_dependency 'mechanize'
  s.add_dependency 'cachy'
  s.add_dependency 'moneta'
  s.add_dependency 'sidekiq'

  s.add_development_dependency 'rspec', '~> 3.0.0'
end
