# -*- encoding : utf-8 -*-

describe Kabutops::Extensions::Parameterable do
  describe '#params' do
    it 'should define methods' do
      klass = Object.clone
      klass.send(:include, Kabutops::Extensions::Parameterable)
      klass.instance_eval do
        params :method1, :method2
        params :method3
      end
      object = klass.new

      expect(object.methods).to include :params
      expect(object.methods).to include :method1
      expect(object.methods).to include :method2
      expect(object.methods).to include :method3
    end
  end
end
