# coding: utf-8
require "rails_helper"
require "support/textile_examples"
require "support/html_examples"

RSpec.describe MarkupAttributesHelper do
  def rendered_value_of(text)
    subject.body = text
    render_markup(subject.body)
  end

  describe 'with emphasis-only markup' do
    class EmphasisOnly < BasicModel
      textile_attribute :body, allow: :emphasis
    end

    subject { EmphasisOnly.new }

    include_examples 'render textile emphasis'

    include_examples 'sanitizing bad html'
    include_examples 'not render textile strong'
    include_examples 'not render textile block tags'
    include_examples 'not render textile images'
    include_examples 'not render textile links'
    include_examples 'remove arbitrary HTML'

    it 'converts quotes into UTF8 characters' do
      expect(rendered_value_of 'My name is "James"').to eq('My name is “James”')
    end
  end

  describe 'with links-only' do
    class LinksOnly < BasicModel
      textile_attribute :body, allow: :links
    end

    subject { LinksOnly.new }

    include_examples 'render textile links'

    include_examples 'sanitizing bad html'
    include_examples 'not render textile strong'
    include_examples 'not render textile emphasis'
    include_examples 'not render textile block tags'
    include_examples 'not render textile images'
    include_examples 'remove arbitrary HTML'

    it 'adds a rel=nofollow attribute to all links' do
      expect(rendered_value_of 'this is a "link":http://example.com').to match('this is a <a href="http://example.com" rel="nofollow">link</a>')
    end
  end

  describe 'with a combination of allowed markup' do
    class EmphasisAndLinksMarkup < BasicModel
      textile_attribute :body, allow: [:emphasis, :links]
    end

    subject { EmphasisAndLinksMarkup.new }

    include_examples 'sanitizing bad html'

    include_examples 'render textile emphasis'
    include_examples 'render textile links'
    include_examples 'not render textile strong'
    include_examples 'not render textile block tags'
    include_examples 'not render textile images'

    it 'adds a rel=nofollow attribute to all links' do
      expect(rendered_value_of 'this is a "link":http://example.com').to match('this is a <a href="http://example.com" rel="nofollow">link</a>')
    end
  end

  describe 'without images' do
    class NoImagesMarkup < BasicModel
      textile_attribute :body, deny: :images
    end

    subject { NoImagesMarkup.new }

    include_examples 'sanitizing bad html'

    include_examples 'render textile emphasis'
    include_examples 'render textile strong'
    include_examples 'render textile block tags'
    include_examples 'render textile links'
    include_examples 'allow arbitrary HTML'

    include_examples 'not render textile images'
  end

  describe 'with full markup' do
    class FullMarkup < BasicModel
      textile_attribute :body
    end

    subject { FullMarkup.new }

    include_examples 'sanitizing bad html'

    include_examples 'render textile emphasis'
    include_examples 'render textile strong'
    include_examples 'render textile block tags'
    include_examples 'render textile images'
    include_examples 'render textile links'
    include_examples 'allow arbitrary HTML'

    it 'converts quotes into smart quote characters' do
      expect(rendered_value_of 'My name is "James"').to eq('<p>My name is “James”</p>')
    end
  end

  describe 'when attribute is globalized' do
    class TranslatedModel < BasicModel
      translates :title, :string
      textile_attribute :title, allow: :emphasis
      textile_attribute :body, allow: :emphasis
    end

    subject { TranslatedModel.new }

    it 'renders default and localised versions of attributes as textile' do
      subject.title = '_emphasise_ this'
      I18n.with_locale('fr-FR') { subject.title = '_zut_ alors!' }

      subject.save
      subject.reload

      expect(render_markup(subject.title)).to match_html('<em>emphasise</em> this')
      I18n.with_locale('fr-FR') do
        expect(render_markup(subject.title)).to match_html('<em>zut</em> alors!')
      end
    end
  end
end
