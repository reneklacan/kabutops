class Nokogiri::HTML::Document
  def == other
    to_html == other.to_html
  end
end
