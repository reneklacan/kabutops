# -*- encoding : utf-8 -*-

require 'json'
require 'hashie'
require 'sidekiq'
require 'cachy'
require 'moneta'
require 'pstore'
require 'mechanize'
require 'elasticsearch'
require 'redis'
require 'redis-namespace'
require 'mongo'
require 'mysql2'
require 'logger'

require 'kabutops/configuration'

Cachy.cache_store = Moneta.new(:File, dir: 'cache') # temporary

require 'kabutops/extensions/includable'
require 'kabutops/extensions/logging'
require 'kabutops/extensions/parameterable'
require 'kabutops/extensions/callback_support'
require 'kabutops/recipe'
require 'kabutops/recipe_item'
require 'kabutops/adapters/base'
require 'kabutops/adapters/database_adapter'
require 'kabutops/adapters/elastic_search'
require 'kabutops/adapters/redis'
require 'kabutops/adapters/mongo'
require 'kabutops/crawler_extensions/elastic_search'
require 'kabutops/crawler_extensions/redis'
require 'kabutops/crawler_extensions/mongo'
require 'kabutops/crawler_extensions/pstore_storage'
require 'kabutops/crawler_extensions/debugging'
require 'kabutops/crawler'
require 'kabutops/watchdog'
