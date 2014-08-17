# -*- encoding : utf-8 -*-

describe Kabutops::Adapters::Mongo do
  before :each do
    @adapter = Kabutops::Adapters::Mongo.clone.new
    @adapter.instance_eval do
      @@client = nil
      @@client_db = nil
      @@collection = nil
    end
    @resource = {
      id: '123',
      color: 'white',
    }
  end

  describe '#store' do
    it 'should try to insert' do
      collection = double('collection')
      allow(collection).to receive(:find).and_return([])
      allow(collection).to receive(:insert).and_return(nil)

      @adapter.instance_eval { @@collection = collection }
      @adapter.store(@resource)

      expect(collection).to have_received(:insert).with(@resource)
    end

    it 'should try to update' do
      collection = double('collection')
      existing = [@resource.clone.update('_id' => @resource[:id])]
      allow(collection).to receive(:find).and_return(existing)
      allow(collection).to receive(:update).and_return(nil)

      @adapter.instance_eval { @@collection = collection }
      @adapter.store(@resource)

      expected = [{'_id' => @resource[:id]}, @resource]
      expect(collection).to have_received(:update).with(*expected)
    end
  end

  describe '#client' do
    it 'should return proper instance' do
      expect(@adapter.send(:client)).to be_a Mongo::MongoClient
    end
  end

  describe '#client_db' do
    it 'should return proper instance' do
      client = double('client')
      client_db = double('client_db')
      allow(client).to receive(:db).and_return(client_db)
      @adapter.instance_eval { @@client = client }
      expect(@adapter.send(:client_db)).to eq client_db
    end
  end

  describe '#collection' do
    it 'should return proper instance' do
      client_db = double('client_db')
      collection = double('collectio')
      allow(client_db).to receive(:collection).and_return(collection)
      @adapter.instance_eval { @@client_db = client_db }
      expect(@adapter.send(:collection)).to eq collection
    end
  end
end

