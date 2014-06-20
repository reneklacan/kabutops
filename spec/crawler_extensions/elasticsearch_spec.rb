# -*- encoding : utf-8 -*-

describe Kabutops::CrawlerExtensions::ElasticSearch do
  before(:each) do
    @crawler_class = Fakes::FakeCrawler.clone
    @crawler_class.class_eval do
      include Kabutops::CrawlerExtensions::ElasticSearch
    end
    @crawler = @crawler_class.new
  end

  describe '#callback' do
    it 'should add right adapter' do
      original_adapter_count = @crawler_class.adapters.count
      @crawler_class.elasticsearch {}
      expect(@crawler_class.adapters.count).to eq original_adapter_count + 1
      expect(@crawler_class.adapters[-1]).to be_a Kabutops::Adapters::ElasticSearch
    end
  end
end

