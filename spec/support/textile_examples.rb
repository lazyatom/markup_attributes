RSpec.shared_examples 'render textile links' do
  it 'allows links to be rendered' do
    expect(rendered_value_of 'this is a "link":http://example.com').to include_markup_tags(:a)
  end
end

RSpec.shared_examples 'not render textile links' do
  specify do
    expect(rendered_value_of 'this is a "link":http://example.com').not_to include_markup_tags(:a)
  end
end

RSpec.shared_examples 'render textile images' do
  specify { expect(rendered_value_of "This is an !/image.jpg!").to include_markup_tags(:img) }
end

RSpec.shared_examples 'not render textile images' do
  specify { expect(rendered_value_of "This is an !/image.jpg!").not_to include_markup_tags(:img) }
end

RSpec.shared_examples 'render textile emphasis' do
  specify { expect(rendered_value_of 'some _nice_ text').to include_markup_tags(:em) }
end

RSpec.shared_examples 'not render textile emphasis' do
  specify { expect(rendered_value_of 'some _nice_ text').not_to include_markup_tags(:em) }
end

RSpec.shared_examples 'render textile strong' do
  specify { expect(rendered_value_of 'some *strong* text').to include_markup_tags(:strong) }
end

RSpec.shared_examples 'not render textile strong' do
  specify { expect(rendered_value_of 'some *strong* text').not_to include_markup_tags(:strong, :b) }
end

RSpec.shared_examples 'render textile block tags' do
  it 'renders text in blocks into paragraphs' do
    expect(rendered_value_of "Some\n\ntext").to match_html("<p>Some</p><p>text</p>")
  end

  it 'renders bulleted text into lists' do
    expect(rendered_value_of "* this\n* is a\n* list").to match_html('<ul><li>this</li><li>is a</li><li>list</li></ul>')
  end
end

RSpec.shared_examples 'not render textile block tags' do
  specify { expect(rendered_value_of "Paragraph 1\n\nParagraph 2").not_to include_markup_tags(:p, :br) }
  specify { expect(rendered_value_of "* this\n* is a\n* list").not_to include_markup_tags(:ul, :li) }
end
