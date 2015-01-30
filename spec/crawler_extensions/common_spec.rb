# -*- encoding : utf-8 -*-

{
  Kabutops::Extensions::Parameterable => [
    :params,
  ],
  Kabutops::Extensions::CallbackSupport=> [
    :callbacks,
  ],
  Kabutops::CrawlerExtensions::Debugging => [
    :debug_first,
    :debug_random,
    :debug_last,
    :debug_resource,
    :enable_debug,
  ],
  Kabutops::CrawlerExtensions::ElasticSearch => [
    :elasticsearch,
  ],
  Kabutops::CrawlerExtensions::PStoreStorage => [
    :storage,
  ],
}.each do |extension, methods|
  describe extension do
    before(:each) do
      @original_class = Object.clone
      @extended_class = Object.clone
      @extended_class.class_eval do
        include extension
      end
    end

    describe 'included methods' do
      it 'should not be included' do
        methods.each do |method|
          expect(@original_class.methods).not_to include method
        end
      end

      it 'should be included' do
        methods.each do |method|
          expect(@extended_class.methods).to include method
        end
      end
    end

  end
end

{
  elasticsearch: [
    Kabutops::CrawlerExtensions::ElasticSearch,
    Kabutops::Adapters::ElasticSearch,
  ],
}.each do |name, classes|
  extension, adapter = classes

  describe extension do
    before(:each) do
      @crawler_class = Kabutops::Crawler.clone
    end

    describe '#callback' do
      it 'should add right adapter' do
        original_adapter_count = @crawler_class.adapters.count
        @crawler_class.send(name) {}
        expect(@crawler_class.adapters.count).to eq original_adapter_count + 1
        expect(@crawler_class.adapters[-1]).to be_a adapter
      end
    end
  end
end
