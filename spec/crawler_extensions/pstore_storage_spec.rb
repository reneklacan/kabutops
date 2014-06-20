# -*- encoding : utf-8 -*-

describe Kabutops::CrawlerExtensions::PStoreStorage do
  before :each do
    klass = Object.clone
    klass.send(:include, Kabutops::CrawlerExtensions::PStoreStorage)
    @object = klass.new
  end

  it 'should define methods' do
    expect(@object.methods).to include :storage
    expect(@object.class.methods).to include :storage
  end

  it 'should return proper value' do
    expect(@object.storage).to be_a Kabutops::CrawlerExtensions::PStoreStorage::Storage
  end
end

describe Kabutops::CrawlerExtensions::PStoreStorage::Storage do
  before :each do
    @storage = Kabutops::CrawlerExtensions::PStoreStorage::Storage.new
  end

  describe 'initialize' do
    it 'should set instance variable' do
      expect(@storage.instance_variable_get('@storage')).to be_a PStore
    end
  end

  describe '[] + []=' do
    it 'should set and return correct value' do
      10.times do
        key = 10.times.map { ('a'..'z').to_a.sample }.join
        value = rand(1000)
        @storage[key] = value

        expect(@storage[key]).to eq value
      end
    end
  end
end
