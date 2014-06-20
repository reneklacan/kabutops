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
          letter: resource[:letter],
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
      after_save do |hash|
        puts "#{hash[:title]} saved!"
      end
    end
  end
end

GemListCrawler.crawl!
#GemCrawler.crawl!
