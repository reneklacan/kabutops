# -*- encoding : utf-8 -*-

describe Kabutops::Adapters::DatabaseAdapter do
  class MockedDatabaseAdapter < Kabutops::Adapters::DatabaseAdapter
    attr_writer :stalker, :recipe

    def store value
      @stalker.store(value)
    end

    def notify key, *args
      @stalker.notify(key, *args)
    end
  end

  before :each do
    @resource = Hashie::Mash.new(result: 'ok')
    @stalker = double('whatever')
    allow(@stalker).to receive(:store) { |value| value }
    allow(@stalker).to receive(:notify)
    @recipe = double('recipe')
    allow(@recipe).to receive(:process).and_return(@resource)

    @adapter = Kabutops::Adapters::DatabaseAdapter.new
    @mocked_adapter = MockedDatabaseAdapter.new
    @mocked_adapter.stalker = @stalker
    @mocked_adapter.recipe = @recipe
  end

  describe '#data' do
    it 'should set recipe' do
      @adapter.data do
        test_name :css, '.test'
      end

      expect(@adapter.recipe).to be_a Kabutops::Recipe
      expect(@adapter.recipe.items.count).to eq 1
    end
  end

  describe '#process' do
    it 'should call store' do
      @mocked_adapter.process(@resource, :page)
      expect(@stalker).to have_received(:store).once.with(@resource)
      expect(@stalker).to have_received(:notify).once.with(:after_save, @resource)
    end

    it 'should not call store in debug' do
      @mocked_adapter.enable_debug
      @mocked_adapter.process(@resource, nil)
      expect(@stalker).not_to have_received(:store)
      expect(@stalker).not_to have_received(:notify)
    end
  end

  describe '#store' do
    it 'should raise an error' do
      expect{ @adapter.store(:whatever) }.to raise_error(NotImplementedError)
    end
  end

  describe '#nested?' do
    it 'should raise an error' do
      expect{ @adapter.nested? }.to raise_error(NotImplementedError)
    end
  end
end
