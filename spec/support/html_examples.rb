RSpec.shared_examples 'sanitizing bad html' do
  it 'does not allow script tags' do
    expect(rendered_value_of 'I am <script>function();</script> a nice person').to include('I am function(); a nice person')
  end

  it 'returns an HTML safe string' do
    expect(rendered_value_of 'some *text*').to be_html_safe
  end

  it 'never wraps uppercase words in spans' do
    expect(rendered_value_of 'A sentence with a LOUD work').not_to include('<span class="caps">LOUD</span>')
    expect(rendered_value_of 'A sentence with a LOUD work').not_to include_markup_tags(:span)
  end
end

RSpec.shared_examples 'allow arbitrary HTML' do
  specify do
    expect(rendered_value_of "Some <span>arbitrary</span> _mixed_ <a href='url'>tags</a>.").to match_html("<p>Some <span>arbitrary</span><em>mixed</em><a href=\"url\">tags</a>.</p>")
  end
end

RSpec.shared_examples 'remove arbitrary HTML' do
  specify do
    expect(rendered_value_of "<sup>Arbitrary</sup> <div>tags</div>").not_to include_markup_tags(:sup, :div)
  end
end
