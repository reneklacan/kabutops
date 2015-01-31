# -*- encoding : utf-8 -*-

describe Kabutops::Extensions::CallbackSupport do
  subject do
    klass = Class.new
    klass.include(Kabutops::Extensions::CallbackSupport)
    klass.callbacks(callbacks)

    object = klass.new
    allow(object).to receive(:manager).and_return(manager)
    object
  end

  let(:manager) { double('manager') }
  let(:callbacks) { [:foo, :bar, :foobar] }

  describe '#allowed_callbacks' do
    it 'method should be defined and return correct value' do
      expect(subject.methods).to include :allowed_callbacks
      expect(subject.allowed_callbacks).to eq callbacks
    end
  end

  describe '#callbacks' do
    it 'should instance eval on manager' do
      expect(manager).to receive(:foo)
      expect(manager).to receive(:bar)

      subject.callbacks do
        foo {}
        bar {}
      end
    end
  end

  describe '#notify' do
    it 'should delegate to manager' do
      expect(manager).to receive(:notify)
      subject.notify(:coconut)
    end
  end
end

describe Kabutops::Extensions::CallbackSupport::Manager do
  subject { described_class.new(allowed_callbacks) }
  let(:allowed_callbacks) { [:foo, :bar, :foobar] }

  describe '#initialize' do
    it 'sets allowed' do
      expect(subject.allowed).to eq allowed_callbacks
      expect(subject.map).to be_a Hashie::Mash
    end
  end

  describe '#method_missing' do
    it 'adds to map' do
      subject.foo {}
      expect(subject.map.keys).to include 'foo'
    end

    it 'raises an error' do
      expect{ subject.nonsense {} }.to raise_error
    end
  end

  describe '#notify' do
    let(:blocks) { 3.times.map{ |i| double("block#{i}") } }
    let(:map) { { foobar: blocks, foo: double(:do_not_call) } }

    before do
      expect(subject).to receive(:map).at_least(1).times.and_return(map)
    end

    it 'delegates to every block' do
      args = [:boo, :far]

      blocks.each{ |b| expect(b).to receive(:call).with(*args) }
      subject.notify(:foobar, *args)
    end
  end
end
