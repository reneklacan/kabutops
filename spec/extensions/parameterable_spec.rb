# -*- encoding : utf-8 -*-

describe Kabutops::Extensions::Parameterable do
  describe '#params' do
    it 'defines methods' do
      klass = Class.new
      klass.include(Kabutops::Extensions::Parameterable)
      klass.params(:method1, :method2)
      klass.params(:method3)
      object = klass.new

      expect(object.methods).to include :params
      expect(object.methods).to include :method1
      expect(object.methods).to include :method2
      expect(object.methods).to include :method3
    end
  end
end
