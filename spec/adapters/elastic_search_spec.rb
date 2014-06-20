# -*- encoding : utf-8 -*-

describe Kabutops::Adapters::ElasticSearch do
  before :each do
    @adapter = Kabutops::Adapters::ElasticSearch.new
    @adapter.instance_eval do
      @@client = nil
    end
  end

  describe '#store' do
    it 'should try to index' do
      client = double('client')
      allow(client).to receive(:index).and_return(nil)
      expected_args = {
        index: 'fruit',
        type: 'onion',
        id: '123',
        body: {
          id: '123',
          color: 'white',
        }
      }

      @adapter.instance_eval { @@client = client }
      @adapter.index expected_args[:index]
      @adapter.type expected_args[:type]
      @adapter.store(expected_args[:body])

      expect(client).to have_received(:index).with(expected_args)
    end
  end

  describe '#nested?' do
    it 'should return true' do
      expect(@adapter.nested?).to eq true
    end
  end

  describe '#client' do
    it 'should return proper instance' do
      expect(@adapter.send(:client)).to be_a Elasticsearch::Transport::Client
    end

    it 'should be with default values' do
      expect(@adapter.send(:client).transport.hosts.count).to eq 1
      expect(@adapter.send(:client).transport.hosts.first[:host]).to eq 'localhost'
      expect(@adapter.send(:client).transport.hosts.first[:port]).to eq '9200'
    end

    it 'should be set accourding to parameters' do
      @adapter.host 'yuna.sk'
      @adapter.port '7777'

      expect(@adapter.send(:client).transport.hosts.count).to eq 1
      expect(@adapter.send(:client).transport.hosts.first[:host]).to eq 'yuna.sk'
      expect(@adapter.send(:client).transport.hosts.first[:port]).to eq '7777'
    end
  end
end
