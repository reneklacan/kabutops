# -*- encoding : utf-8 -*-

class CustomCrawler < Kabutops::Crawler
end

describe CustomCrawler do
  subject do
    subject = subject_class.new
    allow(subject).to receive(:logger).and_return(logger)
    subject
  end
  let(:subject_class) do
    name = 'Crawler_' + SecureRandom.hex
    eval("class #{name} < Kabutops::Crawler; end")
    name.constantize
  end
  let(:logger) { double(:logger) }
  let(:adapters) { 10.times.map{ double(:adapter) } }
  let(:resource) { Hashie::Mash.new(id: 123, url: 'http://yuna.sk/fruit') }
  let(:agent) { double(:agent, page: page) }
  let(:page) do
    double(
      :page,
      body: '<body><some></some></body>',
      to_html: 'html'
    )
  end

  describe 'class methods' do
    describe '#adapters' do
      it 'updates adapters' do
        expect(subject_class.adapters).to eq []
        subject_class.adapters.push('list', 'of', 'adapters')
        expect(subject_class.adapters).not_to be_empty
      end
    end

    describe '#crawl!' do
      it 'creates job for every resource' do
        collection = 5.times.map{ |id| resource.clone.update(id: id) }
        expect {
          subject_class.crawl! collection
        }.to change(subject_class.jobs, :size).by(5)
      end

      it 'doesnt create task and stores it in params collection' do
        collection = 5.times.map{ resource }
        subject_class.enable_debug
        subject_class.crawl! collection

        expect(subject_class.params[:collection]).to eq collection
        expect(subject_class.jobs.size).to eq 0
      end
    end

    describe '#<<' do
      it 'raises an error' do
        expect{ subject_class << {} }.to raise_error
      end

      it 'creates one job' do
        expect {
          subject_class << resource
        }.to change(subject_class.jobs, :size).by(1)
      end

      it 'doesnt create a job' do
        subject_class.enable_debug
        subject_class << resource

        expect(subject_class.jobs.size).to eq 0
        expect(subject_class.params[:collection]).to eq [resource]
      end
    end
  end

  describe 'instances methods' do
    describe '#perform' do
      it 'delegeter to every adapter' do
        allow(subject).to receive(:get_page).and_return(page)
        adapters.each{ |a| expect(a).to receive(:process).with(resource, page) }
        subject_class.adapters.push(*adapters)

        subject.perform(resource)
      end

      context 'error handling' do
        it 'logs and raises error' do
          allow(subject).to receive(:crawl).and_raise(Mechanize::ResponseCodeError.new(double(code: 500)))
          expect(logger).to receive(:error).at_least(1).times

          expect {
            subject.perform(resource)
          }.to raise_error(Mechanize::ResponseCodeError)
        end

        it 'just raises error' do
          allow(subject).to receive(:crawl).and_raise(Mechanize::ResponseCodeError.new(double(code: 500)))
          subject_class.enable_debug

          expect {
            subject.perform(resource)
          }.to raise_error(Mechanize::ResponseCodeError)
        end
      end
    end

    describe '#<<' do
      it 'calls class method' do
        allow(subject_class).to receive(:<<).and_return(:foo)
        expect(subject << :whatever).to eq (subject_class << :whatever)
      end
    end

    describe '#crawl' do
      it 'returns nokogiri document' do
        allow(subject).to receive(:agent).and_return(agent)
        expect(agent).to receive(:get).with(resource[:url]).and_return(page)

        result = subject.crawl(resource)

        expect(result).to be_a Nokogiri::HTML::Document
        expect(result.to_html).to include page.body
      end

      context 'error handling' do
        it 'raises an error' do
          allow(subject).to receive(:get_cache_or_hit).and_raise(Mechanize::ResponseCodeError.new(double(code: 500)))
          expect(logger).to receive(:error).at_least(1).times

          expect {
            subject.crawl(resource)
          }.to raise_error(Mechanize::ResponseCodeError)
        end

        it 'returns nil when page doesnt exist (404)' do
          allow(subject).to receive(:get_cache_or_hit).and_raise(Mechanize::ResponseCodeError.new(double(code: 404)))
          expect(subject.crawl(resource)).to be_nil
        end
      end
    end

    describe '#agent' do
      it 'defaults to instance of Mechanize' do
        expect(subject.agent).to be_a Mechanize
      end

      it 'sets proxy' do
        subject_class.proxy 'yuna.sk', 987

        expect(subject.agent).to be_a Mechanize
        expect(subject.agent.proxy_addr).to eq 'yuna.sk'
        expect(subject.agent.proxy_port).to eq 987
      end

      it 'doesnt create new agent every time' do
        agent_ids = 10.times.map{ subject.agent.object_id }
        expect(agent_ids.uniq.count).to eq 1
      end
    end
  end
end
