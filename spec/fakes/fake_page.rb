module Fakes
  FAKE_PAGE_CONTENT = %Q{
    <html>
      <head>
        <title>Fake</title>
      </head>
      <body>
        <div class="container red">
          <div class="header">
            <h1 id="title">%{title}</h1>
            <p id="desc">%{description}</p>
          </div>

          <table class="table table-stripped">
            <tbody>
              <tr>
                <td>1.</td>
                <td>%{table_first}</td>
              </tr>
              <tr>
                <td>2.</td>
                <td>%{table_second}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </body>
    </html>
  }

  class FakePage
    attr_reader :document

    def initialize
      @document = Nokogiri::HTML(FAKE_PAGE_CONTENT % params)
    end

    def method_missing name, *args, &block
      if params.include?(name)
        params[name]
      else
        @document.public_send(name, *args, &block)
      end
    end

    def body
      to_html
    end

    def params
      {
        title: 'Fake Page',
        description: 'Fake Page Description',
        table_first: 'Corn',
        table_second: 'Papaya',
      }
    end
  end
end
