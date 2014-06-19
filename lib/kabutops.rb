# -*- encoding : utf-8 -*-

require 'hashie'
require 'sidekiq'
require 'cachy'
require 'moneta'
require 'pstore'
require 'mechanize'
require 'elasticsearch'

Cachy.cache_store = Moneta.new(:File, dir: 'cache') # temporary

require 'kabutops/extensions/parameterable'
require 'kabutops/extensions/callback_support'
require 'kabutops/recipe'
require 'kabutops/recipe_item'
require 'kabutops/adapters/base'
require 'kabutops/adapters/database_adapter'
require 'kabutops/adapters/elastic_search'
require 'kabutops/crawler_extensions/elastic_search'
require 'kabutops/crawler_extensions/pstore_storage'
require 'kabutops/crawler_extensions/debugging'
require 'kabutops/crawler'
