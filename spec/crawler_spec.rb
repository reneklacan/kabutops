# -*- encoding : utf-8 -*-

describe Kabutops::Crawler do
  class MockedCrawler < Kabutops::Crawler
    attr_writer :agent

    class << self
      attr_writer :stalker, :adapters

      def perform_async resource
        @stalker.perform_async(resource)
      end
    end
  end

  before :each do
    @page = Fakes::FakePage.new
    @stalker = double('whatever')
    allow(@stalker).to receive(:perform_async)
    @adapters = 10.times.map{ double('adapter') }
    @adapters.each do |adapter|
      allow(adapter).to receive(:process)
      allow(adapter).to receive(:enable_debug)
    end
    @agent = double('agent')
    allow(@agent).to receive(:get).and_return(@page)

    @crawler_class = MockedCrawler.clone
    @crawler_class.stalker = @stalker
    @crawler = @crawler_class.new

    @resource = Hashie::Mash.new(id: 123, url: 'http://yuna.sk/fruit')
  end

  describe 'class methods' do
    describe '#adapters' do
      it 'should return correct value' do
        expect(@crawler.class.instance_variable_get('@adapters')).to be_nil
        expect(@crawler.class.adapters).to eq []

        @crawler.class.instance_variable_set('@adapters', ['list', 'of', 'adapters'])

        expect(@crawler.class.adapters).not_to eq []
        expect(@crawler.class.adapters.count).to be >= 1
      end
    end

    describe '#crawl!' do
      it 'should end up with perform_async call for each resource' do
        collection = 5.times.map{ |id| @resource.clone.update(id: id) }
        @crawler_class.crawl! collection

        expect(@stalker).to have_received(:perform_async).exactly(5).times
      end

      it 'it should call perform_async only once because of duplicates' do
        collection = 5.times.map{ @resource }
        @crawler_class.crawl! collection

        expect(@stalker).to have_received(:perform_async).once.with(@resource)
      end

      it 'should store to params collection' do
        collection = 5.times.map{ @resource }
        @crawler_class.enable_debug
        @crawler_class.crawl! collection

        expect(@crawler_class.params[:collection]).to eq collection
        expect(@stalker).to_not have_received(:perform_async)
      end
    end

    describe '#<<' do
      it 'should raise an error' do
        expect { @crawler_class << {} }.to raise_error
      end

      it 'should call perform_async once' do
        @crawler_class << @resource
        expect(@stalker).to have_received(:perform_async).once.with(@resource.to_hash)
      end

      it 'should call perform_async only once' do
        10.times { @crawler_class << @resource }
        expect(@stalker).to have_received(:perform_async).once.with(@resource.to_hash)
      end

      it 'shoud not call perform_async' do
        @crawler_class.enable_debug
        @crawler_class << @resource

        expect(@stalker).to_not have_received(:perform_async)
        expect(@crawler_class.params[:collection]).to eq [@resource]
      end
    end
  end

  describe 'instances methods' do
    describe '#perform' do
      it 'should call every adapter' do
        @crawler_class.adapters = @adapters
        @crawler.agent = @agent
        @crawler.perform(@resource)

        @adapters.each do |adapter|
          expect(adapter).to have_received(:process).once.with(@resource, @page.document)
        end
      end
    end

    describe '#<<' do
      it 'shoud return same value as class method' do
        @crawler_class.instance_eval do
          def << resource
            'cherry'
          end
        end

        expect(@crawler << :whatever).to eq (@crawler_class << :whatever)
      end
    end

    describe '#crawl' do
      it 'should call an agent' do
        @crawler.agent = @agent
        result = @crawler.send(:crawl, @resource)

        expect(result).to be_a Nokogiri::HTML::Document
        expect(result.to_html).to eq @page.to_html
        expect(@agent).to have_received(:get).with(@resource[:url])
      end
    end

    describe '#agent' do
      it 'should return correct value' do
        expect(@crawler.send(:agent)).to be_a Mechanize
      end

      it 'should set proxy' do
        crawler_class = Kabutops::Crawler.clone
        crawler_class.instance_eval do
          proxy 'yuna.sk', 987
        end
        proxy_crawler = crawler_class.new

        expect(proxy_crawler.send(:agent)).to be_a Mechanize
        expect(proxy_crawler.send(:agent).proxy_addr).to eq 'yuna.sk'
        expect(proxy_crawler.send(:agent).proxy_port).to eq 987
      end

      it 'should not create new agent every time' do
        agent_ids = 10.times.map{ @crawler.send(:agent).object_id }
        expect(agent_ids.uniq.count).to eq 1
      end
    end
  end
end
