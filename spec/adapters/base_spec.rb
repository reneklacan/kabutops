# -*- encoding : utf-8 -*-

describe Kabutops::Adapters::Base do
  subject { described_class.new }

  describe '#initialize' do
    it 'yields block' do
      expect{ |b| described_class.new(&b) }.to yield_with_args(instance_of(described_class))
    end
  end

  describe '#enable_debug & #debug' do
    it 'sets instance variable' do
      expect(subject.debug).to be_falsy
      subject.enable_debug
      expect(subject.debug).to be_truthy
    end
  end
end
