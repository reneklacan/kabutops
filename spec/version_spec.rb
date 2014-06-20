# -*- encoding : utf-8 -*-

describe Kabutops do
  it 'should defined version' do
    expect(Kabutops::VERSION).to match(/^\d+\.\d+\.\d+$/)
  end
end
