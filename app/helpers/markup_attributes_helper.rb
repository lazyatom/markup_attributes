# The top-level Rails helper which enables consistent rendering of markup attributes.
#
# Rails will make this automatically available in your views; you may need to explicitly
# include it in other places (like serializers).
#
# This helper exposes a single method: +render_markup+
module MarkupAttributesHelper

  # Given an attribute, returned an HTML-safe, rendered version of the content
  # in that attribute, rendered according to the markup options defined in the model.
  #
  # If the passed attribute has not been configured as a markup attribute, it will be
  # returned without performing any rendering at all. Th ft ft
  #
  # @param markup_attribute [String] the attribute to render. If this is an attribute that
  #   has not been configured as a markup attribute, it will be returned without any rendering.
  # @example rendering an attribute from a model
  #    # Given this model exists somewhere, with `title` as a markup attribute:
  #    # post = Post.new(title: '"This":http://example.com is _great_')
  #
  #    render_markup(post.title) # => '<a href="http://example.com" rel="nofollow">This</a> is <em>great</em>'
  def render_markup(markup_attribute)
    return markup_attribute if markup_attribute.blank?

    if markup_attribute.respond_to?(:markup_options)
      options = markup_attribute.markup_options

      html = case options[:markup]
      when :textile
        require 'redcloth'
        RedCloth.new(sanitize_using_app(markup_attribute), [:no_span_caps]).to_html
      else
        raise "unknown markup attribute type: #{options[:markup]}"
      end

      cleaned_html = clean_rendered_markup(html, options)
      cleaned_html.html_safe
    end
  end

  private

  def clean_rendered_markup(html, options)
    cleaned_html = if options[:allow] == [:all]
      denied_tags = tags_from_tag_types(*options[:deny])
      allowed_tags = Rails::Html::WhiteListSanitizer.allowed_tags.reject { |tag| denied_tags.include?(tag.to_s) }
      whitelisted_html = Rails::Html::WhiteListSanitizer.new.sanitize(html, tags: allowed_tags).strip
      whitelisted_html
    else
      allowed_tags = tags_from_tag_types(*options[:allow])
      cleaned_html = Rails::Html::WhiteListSanitizer.new.sanitize(html, tags: allowed_tags).strip
      cleaned_html = Loofah.scrub_fragment(cleaned_html, :nofollow).to_html if options[:allow].include?(:links)
      cleaned_html
    end

    cleaned_html
  end

  def tags_from_tag_types(*tag_types)
    tags = []
    tags += %w(i em) if tag_types.include?(:emphasis)
    tags += %w(a) if tag_types.include?(:links)
    tags += %w(img) if tag_types.include?(:images)
    tags
  end

  def sanitize_using_app(string)
    if respond_to?(:sanitize)
      sanitize(string)
    elsif ActionView::Base.respond_to?(:white_list_sanitizer)
      ActionView::Base.white_list_sanitizer.sanitize(string)
    else
      raise "I don't know how to sanitize content, none of my expected ways will work."
    end
  end
end
