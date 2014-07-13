# -*- encoding : utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)

require 'kabutops'

class RubygemsSpider < Kabutops::Spider
  url 'https://rubygems.org/'
  cache true

  callbacks do
    follow_if do |href|
      true if href.include?('/gems')
    end

    after_crawl do |resource, page|
      # do something, eg. add links to crawl manually via <<
    end
  end
end

class GemCrawler < Kabutops::Crawler
  cache true
  wait 2 # wait two seconds after each procession (we do not want to hurt rubygems)

  elasticsearch do
    index :gems
    type :gem

    data do
      id :css, '.title > h2 > a'
      title :css, '.title > h2 > a'
      authors :css, '.authors > p'
      description :css, '#markup > p'

      downloads do
        total :lambda, ->(resource, page) {
          page.css('.downloads.counter > span > strong')[0].text.gsub(',', '').to_i
        }

        current_version :lambda, ->(resource, page) {
          page.css('.downloads.counter > span > strong')[1].text.gsub(',', '').to_i
        }
      end
    end

    callbacks do
      after_save do |hash|
        puts "#{hash[:title]} saved!"
      end
    end
  end
end

RubygemsSpider.debug_spider
#GemCrawler.crawl!
