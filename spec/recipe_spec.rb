# -*- encoding : utf-8 -*-

describe Kabutops::Recipe do
  let(:recipe) { Kabutops::Recipe.new }
  let(:page) { }
  let(:resource) { Hashie::Mash.new(id: '123', apple: 'green') }

  describe '#initialize' do
    it 'should set values' do
      expect(recipe.items).to eq Hashie::Mash.new
      expect(recipe.nested).to be_falsy
    end
  end

  describe '#method_missing' do
    it 'should add normal item' do
      recipe.normal_attr :css, '.value'

      expect(recipe.items.count).to eq 1
      expect(recipe.items.keys[0]).to eq 'normal_attr'
      expect(recipe.items.values[0]).to be_a Kabutops::RecipeItem
      expect(recipe.items.values[0].type).to eq :css
      expect(recipe.items.values[0].value).to be_a String
      expect(recipe.nested?).to eq false
    end

    it 'should add recipe item' do
      recipe.nested_attr do
        another_attribute :xpath, '//test'
      end

      expect(recipe.items.count).to eq 1
      expect(recipe.items.keys[0]).to eq 'nested_attr'
      expect(recipe.items.values[0]).to be_a Kabutops::RecipeItem
      expect(recipe.items.values[0].type).to eq :recipe
      expect(recipe.items.values[0].value).to be_a Kabutops::Recipe
      expect(recipe.nested?).to eq true
    end
  end

  describe '#process' do
    let(:items) do
      Hashie::Mash.new(
        foo: double('item'),
        bar: double('item'),
      )
    end

    it 'should return correct value' do
      items.each do |_, item|
        expect(item).to receive(:process).with(resource, page, nil)
      end

      expect(recipe).to receive(:items).and_return(items)
      result = recipe.process(resource, page, nil)
      expect(result).to be_a Hashie::Mash
    end
  end
end
