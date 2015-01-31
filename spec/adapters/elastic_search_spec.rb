# -*- encoding : utf-8 -*-

describe Kabutops::Adapters::ElasticSearch do
  subject do
    es = described_class.new
    es.index(ElasticSearchTestSupport::ES_INDEX)
    es.type(ElasticSearchTestSupport::ES_TYPE)
    es
  end
  let(:client) { double(:client) }
  let(:resources) do
    [
      Hashie::Mash.new(id: 344, url: 'http://foo1', name: 'foo', updated_at: Time.now.to_i - 1000),
      Hashie::Mash.new(id: 345, url: 'http://foo2', name: 'bar', updated_at: Time.now.to_i - 2000),
      Hashie::Mash.new(id: 346, url: 'http://foo3', name: 'foobar', updated_at: Time.now.to_i - 4000),
      Hashie::Mash.new(id: 347, url: 'http://foo3', name: 'foobar', updated_at: Time.now.to_i - 8000),
    ]
  end
  let(:random_resource) { resources.sample }

  before do
    ElasticSearchTestSupport.delete_all
    resources.each{ |r| ElasticSearchTestSupport.create(r) }
  end

  after do
    ElasticSearchTestSupport.delete_all
  end

  describe '#store' do
    it 'tries to index' do
      expect {
        subject.store(id: 123, color: 'white')
      }.to change{ ElasticSearchTestSupport.count }.by(1)
    end
  end

  describe '#find' do
    it 'finds correct record' do
      expect(subject.find(random_resource)).to eq random_resource
    end

    it 'returns nil when doesnt exist' do
      expect(subject.find(id: 987, url: 'non_existing')).to eq nil
    end
  end

  describe '#find_outdated' do
    let(:freshness) { 3600 }

    it 'finds only outdated records' do
      expect(subject.find_outdated(freshness)).to eq resources.reject{ |r| r[:updated_at] > Time.now.to_i - freshness }
    end
  end

  describe '#client' do
    it 'returns correct instance' do
      expect(subject.client).to be_a Elasticsearch::Transport::Client
    end

    it 'sets default values' do
      expect(subject.client.transport.hosts.count).to eq 1
      expect(subject.client.transport.hosts.first[:host]).to eq 'localhost'
      expect(subject.client.transport.hosts.first[:port]).to eq '9200'
    end

    it 'should be set accourding to parameters' do
      subject.host 'yuna.sk'
      subject.port '7777'

      expect(subject.client.transport.hosts.count).to eq 1
      expect(subject.client.transport.hosts.first[:host]).to eq 'yuna.sk'
      expect(subject.client.transport.hosts.first[:port]).to eq '7777'
    end
  end
end
