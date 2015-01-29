# -*- encoding : utf-8 -*-

describe Kabutops::Adapters::DatabaseAdapter do
  subject { described_class.new }
  let(:resource) { Hashie::Mash.new(result: 'ok') }
  let(:recipe) { double(:recipe, process: resource) }

  describe '#data' do
    before do
      allow(subject).to receive(:find).and_return(nil)
    end

    it 'creates recipe' do
      subject.data do
        test_name :css, '.test'
      end

      expect(subject.recipe).to be_a Kabutops::Recipe
      expect(subject.recipe.items.count).to eq 1
    end
  end

  describe '#process' do
    before do
      allow(subject).to receive(:recipe).and_return(recipe)
      allow(subject).to receive(:find).and_return(nil)
    end

    it 'calls set of methods' do
      expect(subject).to receive(:notify).once.with(:save_if, resource, :page, resource)
      expect(subject).to receive(:notify).once.with(:before_save, resource)
      expect(subject).to receive(:store).once.with(resource)
      expect(subject).to receive(:notify).once.with(:after_save, resource)

      subject.process(resource, :page)
    end

    it 'doesnt call store method in debug mode' do
      expect(subject).not_to receive(:store)
      expect(subject).to receive(:notify).exactly(3).times

      subject.enable_debug
      subject.process(@resource, nil)
    end

    context 'recipe is nil' do
      let(:recipe) { nil }

      it 'raises exception' do
        expect{ subject.process(@resource, :page) }.to raise_error
      end
    end
  end

  describe '#store' do
    it 'raises exception' do
      expect{ subject.store(:whatever) }.to raise_error(NotImplementedError)
    end
  end

  describe '#find?' do
    it 'raises exception' do
      expect{ subject.find(:whatever) }.to raise_error(NotImplementedError)
    end
  end
end
