$:.push File.expand_path("../lib", __FILE__)

require 'kabutops/version'

Gem::Specification.new do |s|
  s.name        = 'kabutops'
  s.version     = Kabutops::VERSION
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = 'Dead simple yet powerful Ruby crawler for easy parallel crawling with support for an anonymity.'
  s.description = 'Dead simple yet powerful Ruby crawler for easy parallel crawling with support for an anonymity.'
  s.authors     = ['Rene Klacan']
  s.email       = 'rene@klacan.sk'
  s.files       = Dir["{lib}/**/*", "LICENSE", "README.md"]
  s.executables = []
  s.homepage    = 'https://github.com/reneklacan/kabutops'
  s.license     = 'Beerware'

  s.required_ruby_version = '>= 1.9'

  s.add_dependency 'mechanize', '~> 2.7'
  s.add_dependency 'cachy', '~> 0.4'
  s.add_dependency 'moneta', '~> 0.7'
  s.add_dependency 'sidekiq', '~> 3.1'
  s.add_dependency 'elasticsearch', '~> 1.0'
  s.add_dependency 'hashie', '~> 3.0'
  s.add_dependency 'json', '~> 1.8'
  s.add_dependency 'mongo', '~> 1.10'
  s.add_dependency 'bson_ext', '~> 1.10'

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-mocks', '~> 3.0'
end
