# -*- encoding : utf-8 -*-
#
$VERBOSE = nil

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'pry'
require 'sidekiq/testing'
require './lib/kabutops'

Kabutops::Configuration.config do
  logger.level = Logger::WARN
end

Dir[('./spec/support/**/*.rb')].each { |f| require f }
Dir[('./spec/fakes/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.order = :random
end
