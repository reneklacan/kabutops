# -*- encoding : utf-8 -*-

describe Kabutops::CrawlerExtensions::Debugging do
  before(:each) do
    @crawler_class = Fakes::FakeCrawler.clone
    @crawler_class.class_eval do
      include Kabutops::CrawlerExtensions::Debugging
    end
    @crawler = @crawler_class.new
  end

  describe '#debug_resource' do
    it 'shoult return same resource' do
      resource = @crawler_class.params[:collection].sample
      expect(@crawler_class.debug_resource(resource)).to eq resource
    end

    it 'should enable debugging' do
      expect(@crawler_class.debug).to eq false
      @crawler_class.debug_resource @crawler_class.params[:collection].sample
      expect(@crawler_class.debug).to eq true
    end
  end

  describe '#enable_debug' do
    it 'shoult enable debug' do
      expect(@crawler_class.debug).to eq false

      @crawler_class.adapters.each do |adapter|
        expect(adapter.debug).to eq false
      end

      @crawler_class.enable_debug

      expect(@crawler_class.debug).to eq true

      @crawler_class.adapters.each do |adapter|
        expect(adapter.debug).to eq true
      end
    end
  end

  describe '#debug_first' do
    it 'shoult return first resource' do
      expect(@crawler_class.debug_first).to eq @crawler_class.params[:collection][0..0]
    end

    it 'shoult return first three resources' do
      expect(@crawler_class.debug_first(3)).to eq @crawler_class.params[:collection][0..2]
    end
  end 

  describe '#debug_random' do
    it 'shoult return random resources' do
      results = 10.times.map{ @crawler_class.debug_random }
      expect(results.uniq.count).to be > 1
    end
  end 

  describe '#debug_last' do
    it 'shoult return last resource' do
      expect(@crawler_class.debug_last).to eq @crawler_class.params[:collection][-1..-1]
    end

    it 'shoult return last three resources' do
      expect(@crawler_class.debug_last(3)).to eq @crawler_class.params[:collection][-3..-1]
    end
  end 
end
