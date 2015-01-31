# -*- encoding : utf-8 -*-

describe Kabutops::CrawlerExtensions::PStoreStorage do
  subject do
    klass = Object.clone
    klass.send(:include, Kabutops::CrawlerExtensions::PStoreStorage)
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
  let(:storage) { Kabutops::CrawlerExtensions::PStoreStorage::Storage.new }

  describe 'initialize' do
    it 'sets instance variable' do
      expect(storage.instance_variable_get('@storage')).to be_a PStore
    end
  end

  describe '[] + []=' do
    it 'should set and return correct value' do
      10.times do
        key = 10.times.map { ('a'..'z').to_a.sample }.join
        value = rand(1000)
        storage[key] = value

        expect(storage[key]).to eq value
      end
    end
  end
end
