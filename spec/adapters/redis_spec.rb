# -*- encoding : utf-8 -*-

describe Kabutops::Adapters::Redis do
  before :each do
    @adapter = Kabutops::Adapters::Redis.new
    @adapter.instance_eval do
      @@client = nil
    end
  end

  describe '#store' do
    it 'should try to index' do
      client = double('client')
      allow(client).to receive('[]=').and_return(nil)
      resource = {
        id: '123',
        color: 'white',
      }

      @adapter.instance_eval { @@client = client }
      @adapter.store(resource)

      expected_args = [resource[:id], JSON.dump(resource)]
      expect(client).to have_received('[]=').with(*expected_args)
    end
  end

  describe '#nested?' do
    it 'should return true' do
      expect(@adapter.nested?).to eq true
    end
  end

  describe '#client' do
    it 'should return proper instance' do
      expect(@adapter.send(:client)).to be_a Redis::Namespace
    end
  end
end
