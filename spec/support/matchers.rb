RSpec::Matchers.define :include_markup_tags do |*expected_tags|
  match do |actual|
    expected_tags.all? { |tag| Nokogiri::HTML.fragment(actual).css(tag).any? }
  end
  match_when_negated do |actual|
    expected_tags.all? { |tag| Nokogiri::HTML.fragment(actual).css(tag).empty? }
  end
end

RSpec::Matchers.define :match_html do |expected_html|
  match do |actual|
    fragment = Nokogiri::HTML.fragment(actual)
    fragment.xpath(".//child::text()").each { |n| n.remove if n.content.strip.empty? }
    actual_html = fragment.to_html.split(/\n/).join
    expected_html == actual_html
  end
end
