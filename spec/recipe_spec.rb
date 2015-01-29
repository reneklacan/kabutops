# -*- encoding : utf-8 -*-

describe Kabutops::Recipe do
  before :each do
    @recipe = Kabutops::Recipe.new
    @page = Fakes::FakePage.new
    @resource = Hashie::Mash.new(id: '123', apple: 'green')
  end

  describe '#initialize' do
    it 'should set values' do
      expect(@recipe.instance_variable_get("@items")).to eq Hashie::Mash.new
      expect(@recipe.instance_variable_get("@nested")).to eq false
    end
  end

  describe '#method_missing' do
    it 'should add normal item' do
      expect(@recipe.items.count).to eq 0

      @recipe.normal_attr :css, '.value'

      expect(@recipe.items.count).to eq 1
      expect(@recipe.items.keys[0]).to eq 'normal_attr'
      expect(@recipe.items.values[0]).to be_a Kabutops::RecipeItem
      expect(@recipe.items.values[0].type).to eq :css
      expect(@recipe.items.values[0].value).to be_a String
      expect(@recipe.nested?).to eq false
    end

    it 'should add recipe item' do
      expect(@recipe.items.count).to eq 0

      @recipe.nested_attr do
        another_attribute :xpath, '//test'
      end

      expect(@recipe.items.count).to eq 1
      expect(@recipe.items.keys[0]).to eq 'nested_attr'
      expect(@recipe.items.values[0]).to be_a Kabutops::RecipeItem
      expect(@recipe.items.values[0].type).to eq :recipe
      expect(@recipe.items.values[0].value).to be_a Kabutops::Recipe
      expect(@recipe.nested?).to eq true
    end
  end

  describe '#process' do
    it 'should return correct value' do
      items = Hashie::Mash.new(
        watermelon: double('item'),
        cucumber: double('item'),
      )

      values = items.map do |name, item|
        allow(item).to receive(:process) do |resource, page|
          [name, resource.update(name: name), page.title]
        end

        [name, @resource.clone.update(name: name), @page.title]
      end

      @recipe.instance_variable_set("@items", items)

      expect(@recipe.process(@resource, @page, nil)).to be_a Hashie::Mash
      expect(@recipe.process(@resource, @page, nil).keys).to eq ['watermelon', 'cucumber']
      expect(@recipe.process(@resource, @page, nil).values).to eq values
    end
  end

  describe '#nested?' do
    it 'should return true' do
      @recipe.instance_variable_set("@nested", true)
      expect(@recipe.nested?).to eq true
    end

    it 'should return false' do
      @recipe.instance_variable_set("@nested", false)
      expect(@recipe.nested?).to eq false
    end
  end
end
