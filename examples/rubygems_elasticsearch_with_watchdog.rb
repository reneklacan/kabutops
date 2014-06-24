# -*- encoding : utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)

require 'kabutops'

class GemListCrawler < Kabutops::Crawler
  collection ['Q', 'X'].map{ |letter|
               {
                 letter: letter,
                 url: "https://rubygems.org/gems?letter=#{letter}"
               }
             }

  cache true
  wait 2 # wait two seconds after each procession (we do not want to hurt rubygems)

  callbacks do
    after_crawl do |resource, page|
      links = page.xpath("//a[contains(@href, '/gems?letter=#{resource[:letter]}')]")
      links.each do |link|
        GemListCrawler << {
          letter: resource[:letter],
          url: "https://rubygems.org#{link['href']}",
        }
      end

      links = page.xpath("//a[contains(@href, '/gems/')]")
      links.each do |link|
        GemCrawler << {
          url: "https://rubygems.org#{link['href']}",
        }
      end
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
      after_save do |resource|
        puts "#{resource[:title]} saved!"
      end
    end
  end
end

class GemUpdater < Kabutops::Watchdog
  crawler GemCrawler
  freshness 1*24*60*60 # 1 day
  wait 5

  callbacks do
    on_outdated do |resource|
      puts "#{resource[:title]} outdated!"
      GemCrawler << {
        url: resource[:url],
      }
    end
  end
end

GemListCrawler.crawl
GemCrawler.crawl
GemUpdater.check!
