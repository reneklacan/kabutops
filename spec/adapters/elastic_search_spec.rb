# -*- encoding : utf-8 -*-

describe Kabutops::Adapters::ElasticSearch do
  subject { described_class.new }
  let(:client) { double(:client) }

  describe '#store' do
    it 'should try to index' do
      expect(subject).to receive(:client).and_return(client)

      expected_args = {
        index: 'fruit',
        type: 'onion',
        id: '123',
        body: {
          id: '123',
          color: 'white',
        }
      }

      expect(client).to receive(:index).with(expected_args)

      subject.index(expected_args[:index])
      subject.type(expected_args[:type])
      subject.store(expected_args[:body])
    end
  end

  describe '#find' do

  end

  describe '#find_outdated' do

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
