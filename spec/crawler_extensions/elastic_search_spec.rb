# -*- encoding : utf-8 -*-

describe Kabutops::CrawlerExtensions::ElasticSearch do

  describe 'crawler integration' do
    let(:crawler_class) { Class.new(Kabutops::Crawler) }

    it 'adds adapter' do
      expect {
        crawler_class.elasticsearch {}
      }.to change{ crawler_class.adapters.count }.by(1)
      expect(crawler_class.adapters.last).to be_a Kabutops::Adapters::ElasticSearch
    end
  end

end
