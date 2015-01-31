# -*- encoding : utf-8 -*-

describe Kabutops do
  it 'defines version in correct format' do
    expect(Kabutops::VERSION).to match(/^\d+\.\d+\.\d+$/)
  end
end
