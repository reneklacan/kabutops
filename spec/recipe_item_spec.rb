# -*- encoding : utf-8 -*-

describe Kabutops::RecipeItem do
  before :each do
    @page = Fakes::FakePage.new
    @resource = { id: '123', apple: 'green' }
  end

  describe '#initialize' do
    it 'should set values' do
      item = Kabutops::RecipeItem.new('type', 'value')
      expect(item.type).to eq 'type'
      expect(item.value).to eq 'value'
    end
  end

  describe '#process' do
    describe ':var type' do
      it 'should return correct value' do
        item = Kabutops::RecipeItem.new(:var, :apple)
        resource = { apple: 'red' }
        expect(item.process(resource, nil)).to eq 'red'
      end
    end

    describe ':recipe type' do
      it 'should return correct value' do
        recipe = double('recipe')
        mocked_result = { id: '123', apple: 'green' }
        allow(recipe).to receive(:process).and_return(mocked_result)

        item = Kabutops::RecipeItem.new(:recipe, recipe)
        expect(item.process(nil, nil)).to eq mocked_result
      end
    end

    describe ':css type' do
      it 'should return correct value' do
        item = Kabutops::RecipeItem.new(:css, '.container > .header > h1#title')
        expect(item.process(nil, @page)).to eq @page.title
      end

      it 'should return empty string' do
        item = Kabutops::RecipeItem.new(:css, '.some_bullshit')
        expect(item.process(nil, @page)).to eq ''
      end
    end

    describe ':xpath type' do
      it 'should return correct value' do
        item = Kabutops::RecipeItem.new(:xpath, '//table/tbody/tr[2]/td[2]')
        expect(item.process(nil, @page)).to eq @page.table_second
      end

      it 'should return empty string' do
        item = Kabutops::RecipeItem.new(:xpath, '//some_bullshit')
        expect(item.process(nil, @page)).to eq ''
      end
    end

    describe ':lambda type' do
      it 'should return correct value' do
        function = ->(resource, page) { ['potato', resource, page] }
        item = Kabutops::RecipeItem.new(:lambda, function)
        expect(item.process(@resource, @page)).to eq ['potato', @resource, @page]
      end
    end

    describe ':proc type' do
      it 'should return correct value' do
        function = Proc.new { |resource, page| ['pineapple', resource, page] }
        item = Kabutops::RecipeItem.new(:proc, function)
        expect(item.process(@resource, @page)).to eq ['pineapple', @resource, @page]
      end
    end

    describe ':unkwown type' do
      it 'should raise exception' do
        item = Kabutops::RecipeItem.new(:unknown, :whatever)
        expect{ item.process(nil, nil) }.to raise_error
      end
    end
  end
end

