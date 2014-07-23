Kabutops [![Code Climate](https://codeclimate.com/github/reneklacan/kabutops.png)](https://codeclimate.com/github/reneklacan/kabutops) [![Coverage](https://codeclimate.com/github/reneklacan/kabutops/coverage.png)](https://codeclimate.com/github/reneklacan/kabutops)
========

Kabutops is a ruby library whichs aims to simplify creating website crawlers.
You can define what will be crawled and how it will be saved in the short class definition.

With Kabutops you can save data easily to:
* ElasticSearch
* MongoDB
* Redis

Example for every kind of database are located
in the [examples directory](https://github.com/reneklacan/kabutops/tree/master/examples)

Installation
------------

You can install it via gem

```bash
gem install kabutops
```

Or you can put it in your Gemfile

```ruby
gem 'kabutops', '~> 0.1.1'
```

You will also need Redis database installed and running.

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

Staying up to date
------------------

Note: This feature is currently working only with ElasticSearch

For this purpore there is a Watchdog. Updater have to inherit from
this class and this class can be run as a worker via sidekiq or as a
plain ruby script as you can see below.

```ruby
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

GemUpdater.loop
```

```bash
ruby rubygems_updater.rb
```

Anonymity ala Tor
-----------------

Anonymity can be easily achieved with [Peasant](https://github.com/reneklacan/peasant) gem.
By following [this guide](https://github.com/reneklacan/peasant/wiki/How-to-use-Peasant-with-Tor-and-Privoxy-for-scraping)
you can create proxy instance that will forward requests to
multiple tor instances.

Then use Peasant proxy address in your Crawler class definition

```ruby
class MyCrawler < Kabutops::Crawler
  ...
  proxy 'localhost', 81818
  ...
end
```

Javascript heavy site
---------------------

Crawling this kind of sites can be achieved by using non-default agent
(default is Mechanize.new).

```ruby
class MyCrawler < Kabutops::Crawler
  ...
  agent Bogeyman::Client.new
  ...
end
```

[Bogeyman](https://github.com/reneklacan/bogeyman-ruby-client)
is wrapper build upon Phantomjs.

TODO
----

* Watchdog for Mongo
* skip_existing feature for Mongo, Redis

License
-------

This library is distributed under the Beerware license.
