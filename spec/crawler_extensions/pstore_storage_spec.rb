# -*- encoding : utf-8 -*-

describe Kabutops::CrawlerExtensions::PStoreStorage do
  subject do
    klass = Class.new
    klass.include(described_class)
    klass.new
  end

  it 'defines methods' do
    expect(subject.methods).to include :storage
    expect(subject.class.methods).to include :storage
  end

  it 'has a storage' do
    expect(subject.storage).to be_a Kabutops::CrawlerExtensions::PStoreStorage::Storage
  end
end

describe Kabutops::CrawlerExtensions::PStoreStorage::Storage do
  subject { described_class.new }

  describe 'initialize' do
    it 'sets instance variable' do
      expect(subject.storage).to be_a PStore
    end
  end

  describe '[] + []=' do
    it 'returns correct value' do
      10.times do
        key = 10.times.map { ('a'..'z').to_a.sample }.join
        value = rand(1000)
        subject[key] = value

        expect(subject[key]).to eq value
      end
    end
  end
end
