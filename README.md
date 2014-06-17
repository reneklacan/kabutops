Kabutops
========

Installation
------------

You can install it via gem

```bash
gem install kabutops
```

Or you can put it in your Gemfile

```ruby
gem 'kabutops'
```

Basic example
-------------

Create **fruit_crawler.rb**.

```ruby
require 'kabutops'

class FruitCrawler < Kabutops::Crawler
  include Sidekiq::Worker

  collection (1..5).map { |id|
               {
                 id: id,
                 url: "https://www.goodreads.com/book/show/#{id}",
               }
             }.shuffle
  proxy '127.0.0.1', 81818
  cache true

  elasticsearch do
    index :books
    document :book

    data do
      id :var, :id
      url :var, :url
      some_attr :css, 'h1.bookTitle'
      grape :lambda, ->(page) {
        page.css('h3.fruit').split(',').first 
      }

      nested_attr do
        apple :css, 'h1.bookTitle'
        banana :xpath, '//table/tr/td[0]'
      end
    end
  end

  callback do |resource, page|
  end
end

FruitCrawler.crawl!
```

Run it via sidekiq

```bash
bundle exec sidekiq -r ./fruit_crawler.rb -c 10
```

This example will parallely crawl specified urls and result will be
stored to the ElasticSearch index named books as a book document.

One document will look something like this

```json
{
  'id': '...',
  'url': '...',
  'some_attr': '...',
  'grape': '...',
  'nested_attr': {
    'apple': '...',
    'banana': '...'
  }
}
```
