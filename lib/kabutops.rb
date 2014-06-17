require 'sidekiq'
require 'cachy'
require 'moneta'
require 'pstore'

Cachy.cache_store = Moneta.new(:File, dir: 'cache') # temporary

require 'kabutops/recipe'
require 'kabutops/recipe_item'
require 'kabutops/adapters/callback'
require 'kabutops/adapters/database_adapter'
require 'kabutops/adapters/elastic_search'
require 'kabutops/adapters/mysql'
require 'kabutops/crawler_extensions/callback'
require 'kabutops/crawler_extensions/elastic_search'
require 'kabutops/crawler_extensions/mysql'
require 'kabutops/crawler_extensions/pstore_storage'
require 'kabutops/crawler'
