require "rails_helper"

RSpec.describe 'using it in a model' do
  class SomeModel< BasicModel
    textile_attribute :body, allow: :emphasis

    include MarkupAttributesHelper
    def rendered_body
      render_markup(body)
    end
  end

  it 'should use the sanitizer from the running Rails application' do
    expect(SomeModel.new(body: '_hello_').rendered_body).to match_html('<em>hello</em>')
  end
end
