# -*- encoding : utf-8 -*-

describe Kabutops::Adapters::Base do
  before :each do
    @base = Kabutops::Adapters::Base.new
  end

  describe '#initialize' do
    it 'should eval block' do
      stalker = double('stalker')
      allow(stalker).to receive(:eval)
      adapter = Kabutops::Adapters::Base.new do
        stalker.eval
      end
      expect(stalker).to have_received(:eval).once
    end
  end

  describe '#enable_debug' do
    it 'should set instance variable' do
      expect(@base.instance_variable_get('@debug')).to eq nil
      @base.enable_debug
      expect(@base.instance_variable_get('@debug')).to eq true
    end
  end

  describe '#debug' do
    it 'shoud return true or false' do
      expect(@base.debug).to eq false
      @base.enable_debug
      expect(@base.debug).to eq true
    end
  end
end
