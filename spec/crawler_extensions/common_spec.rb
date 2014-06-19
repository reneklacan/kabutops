{
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
      @original_class = Fakes::FakeCrawler.clone
      @extended_class = Fakes::FakeCrawler.clone
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
