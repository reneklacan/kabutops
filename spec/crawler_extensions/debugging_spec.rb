# -*- encoding : utf-8 -*-

describe Kabutops::CrawlerExtensions::Debugging do
  class MockedCrawlerForDebugging < Kabutops::Crawler
    class << self
      def params
        {
          collection: (1..100).map{ |id|
            {
              id: id,
              url: "http://example.com/#{id}",
            }
          },
        }
      end

      def adapters
        @adapters ||= 5.times.map{ Fakes::FakeAdapter.new }
      end
    end

    def perform resource
      resource
    end
  end

  before(:each) do
    #@crawler_class = Fakes::FakeCrawler.clone
    @crawler_class = MockedCrawlerForDebugging.clone
    @crawler = @crawler_class.new
  end

  subject do
    klass = Class.new
    klass.include(Kabutops::CrawlerExtensions::Debugging)
    allow(klass).to receive(:adapters).and_return(adapters)
    allow(klass).to receive(:new).and_return(subject_instance)
    allow(klass).to receive(:params).and_return(params)
    klass
  end
  let(:subject_instance) { double(:subject_instance) }
  let(:adapters) { 3.times.map{ double(:adapter) } }
  let(:resources) do
    (1..100).map do |id|
      {
        id: id,
        url: "http://example.com/#{id}",
      }
    end
  end
  let(:random_resource) { resources.sample }
  let(:params) { { collection: resources } }
  let(:random_count) { (2..10).to_a.sample }

  before do
    expect(subject.debug).to be_falsy
    # every method is enabling debug mode for each adapter
    adapters.each{ |a| expect(a).to receive(:enable_debug).at_least(:once) }
  end

  after do
    expect(subject.debug).to be_truthy
  end

  describe '#debug_resource' do
    it 'calls perform with given resource and enables debug mode' do
      expect(subject_instance).to receive(:perform).with(random_resource)
      subject.debug_resource(random_resource)
    end
  end

  describe '#enable_debug' do
    it 'enables debug mode' do
      subject.enable_debug
    end
  end

  describe '#debug_first' do
    it 'debugs first resource' do
      expect(subject_instance).to receive(:perform).with(resources.first)
      subject.debug_first
    end

    it 'debugs first three resources' do
      expect(subject_instance).to receive(:perform).with(resources[0]).ordered
      expect(subject_instance).to receive(:perform).with(resources[1]).ordered
      expect(subject_instance).to receive(:perform).with(resources[2]).ordered
      subject.debug_first(3)
    end
  end

  describe '#debug_random' do
    it 'debugs resources' do
      expect(subject_instance).to receive(:perform).exactly(random_count).times
      subject.debug_random(random_count)
    end
  end

  describe '#debug_last' do
    it 'debugs last resource' do
      expect(subject_instance).to receive(:perform).with(resources.last)
      subject.debug_last
    end

    it 'debugs last three resources' do
      expect(subject_instance).to receive(:perform).with(resources[-1]).ordered
      expect(subject_instance).to receive(:perform).with(resources[-2]).ordered
      expect(subject_instance).to receive(:perform).with(resources[-3]).ordered
      subject.debug_last(3)
    end
  end

  describe '#debug_all' do
    it 'debugs whole collection' do
      expect(subject_instance).to receive(:perform).exactly(resources.count).times
      subject.debug_all
    end
  end
end
