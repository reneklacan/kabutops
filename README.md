Kabutops [![Code Climate](https://codeclimate.com/github/reneklacan/kabutops.png)](https://codeclimate.com/github/reneklacan/kabutops) [![Coverage](https://codeclimate.com/github/reneklacan/kabutops/coverage.png)](https://codeclimate.com/github/reneklacan/kabutops)
========

Installation
------------

You can install it via gem

```bash
gem install kabutops
```

Or you can put it in your Gemfile

```ruby
gem 'kabutops', '~> 0.0.5'
```

Basic example
-------------

Example that will crawl information about gems that start on letter Q or
X and save them to the ElasticSearch.

```ruby
require 'kabutops'

class GemListCrawler < Kabutops::Crawler
  # just two letters with the smallest amount of gems
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
GemCrawler.crawl!
```

Run it via sidekiq

```bash
bundle exec sidekiq -r ./rubygems_crawler.rb -c 1
```

Documents saved in the ElasticSearch will look like this one

```json
{
  "id": "qiita_mail",
  "title": "qiita_mail",
  "authors": "ongaeshi",
  "description":" Write a gem description",
  "downloads": {
    "total": 2493,
    "current_version": 580
  }
}
```

Debugging
---------

As we all know, crawler can't be written on the first time.

Therefore there are methods for debugging

```ruby
FruitCrawler.debug_first # will take first from collection
FruitCrawler.debug_first 7 # will take first 7 resources
FruitCrawler.debug_random # will take random one
FruitCrawler.debug_random 3 # will take 3 random resources
FruitCrawler.debug_last # will take last from collection
FruitCrawler.debug_last 5 # will take last 5 resources
FruitCrawler.debug_all # guess what it will do
FruitCrawler.debug_resource { id: '123', url: '...' }
```

These methods will print out what would be otherwise saved to the
database but for this time there is no save to the database.
