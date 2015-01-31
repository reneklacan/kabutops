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
    subject do
      klass = Class.new
      klass.include(extension)
      klass
    end

    describe 'included methods' do
      methods.each do |method|
        it "includes #{method} method" do
          expect(subject.methods).to include method
        end
      end
    end
  end
end
