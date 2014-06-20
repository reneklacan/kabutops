# -*- encoding : utf-8 -*-

describe Kabutops::Extensions::CallbackSupport do
  before :each do
    klass = Object.clone
    klass.send(:include, Kabutops::Extensions::CallbackSupport)
    klass.instance_eval do
      callbacks :coconut, :goji, :lime
    end

    @manager = double('manager')
    allow(@manager).to receive(:notify)
    allow(@manager).to receive(:peach)
    allow(@manager).to receive(:pistachio)

    @object = klass.new
    @object.instance_variable_set('@manager', @manager)
  end

  describe '#allowed_callbacks' do
    it 'method should be defined and return correct value' do
      expect(@object.methods).to include :allowed_callbacks
      expect(@object.allowed_callbacks).to eq [:coconut, :goji, :lime]
    end
  end

  describe '#callbacks' do
    it 'should instance eval on manager' do
      @object.callbacks do
        peach {}
        pistachio {}
      end

      expect(@manager).to have_received(:peach).once
      expect(@manager).to have_received(:pistachio).once
      expect(@manager).to_not have_received(:notify)
    end
  end

  describe '#notify' do
    it 'should delegate to manager' do
      @object.notify(:coconut)
      expect(@manager).to have_received(:notify).once
    end
  end
end

describe Kabutops::Extensions::CallbackSupport::Manager do
  before :each do
    @allowed_callbacks = [:coconut, :goji, :lime]
    @manager = Kabutops::Extensions::CallbackSupport::Manager.new(@allowed_callbacks)
  end

  describe '#initialize' do
    it 'should set allowed' do
      expect(@manager.allowed).to eq @allowed_callbacks
      expect(@manager.map).to eq Hashie::Mash.new
      expect(@manager.map).to be_a Hashie::Mash
    end
  end

  describe '#method_missing' do
    it 'should add to map' do
      expect(@manager.map.keys).not_to include 'coconut'
      @manager.coconut {}
      expect(@manager.map.keys).to include 'coconut'
    end

    it 'should raise an error' do
      expect{ @manager.bullshit {} }.to raise_error
      expect{ @manager.bullshit }.to raise_error
      expect{ @manager.coconut }.to raise_error
    end
  end

  describe '#notify' do
    it 'should call back' do
      stalker = double('stalker')
      allow(stalker).to receive(:ping).and_return(:pong)
      @manager.coconut { |arg| stalker.ping(arg) }
      @manager.notify(:coconut, :olive)
      expect(stalker).to have_received(:ping).once.with(:olive)
    end
  end
end
