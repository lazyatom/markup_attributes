require "markup_attributes/engine"

# The main behaviour for defining markup attributes
#
# To enable this for your models, either extend it directly into one or more models,
# or extend it into `ApplicationRecord` to include it everywhere
#
# == Markup constraints
# Markup content typically comes from users of the app, and as with any user-generated
# content, we probably can't allow them to insert any old HTML into our rendered pages.
#
# The main benefit of this approach is that it allows us to declare constraints on
# the types of markup we want to deal with in a single place, but without coupling
# rendering logic into the model itself.
#
# Those constraints are grouped into certain types of elements:
#
# Emphasis (:emphasis)::  allow `i` and `em` tags.
# Links (:links)::  allow `a` tags, but mark them as `nofollow` so that they are not useful
#                   for spammers.
# Images (:images):: allow `img` tags.
#
# == Automatic sanitisation
#
# All the HTML generated is automatically run through Rails' own sanitisation mechanism,
# which means that things like `<script>alert();</script>` will automatically either
# be sanitised into a non-running piece of content, or entirely removed, depending on
# the options given.
#
# @example a simple model declaring textile attributes
#   class Post < ApplicationRecord
#     extend MarkupAttributes
#
#     textile_attribute :title, :description, allow: [:emphasis, :images]
#
#     # ...
#   end
module MarkupAttributes
  # A subclass of string which the attributes are cast into by ActiveRecord
  # @private
  class MarkupString < String
    attr_accessor :markup_options
  end

  # The type used by ActiveRecord's attributes API
  # @private
  class MarkupType < ActiveRecord::Type::String
    def self.inspect
      "<MarkupType [#{markup_options}]>"
    end

    def markup_options
      self.class.markup_options
    end

    def cast(value)
      if value.is_a?(String) || value.is_a?(MarkupString)
        MarkupString.new(value).tap { |s| s.markup_options = self.markup_options }
      else
        super
      end
    end
  end

  ActiveRecord::Type.register(:markup, MarkupType)

  # Declare one or more attributes as containing Textile markup.
  # @param (see #markup_attribute)
  # @example An attribute which only supports Textile emphasis and links
  #    textile_attribute :title, allow: [:emphasis, :links]
  # @example An attribute which supports everything except images
  #    textile_attribute :title, deny: [:images]
  def textile_attribute(*attribute_names, **options)
    markup_attribute(*attribute_names, **options.merge(markup: :textile))
  end

  # Declare one or more attributes as containing Markdown markup.
  # @param (see #markup_attribute)
  def markdown_attribute(*attribute_names, **options)
    markup_attribute(*attribute_names, **options.merge(markup: :markdown))
  end

  # Declare one or more attributes as containing markup content
  #
  # == Markup types
  # The following types can be provided in either the +:allow+ or +:deny+ options:
  # :emphasis:: +i+ and +em+ tags
  # :links:: +a+ tags (will all have +rel=nofollow+ automatically set)
  # :images:: +img+ tags
  #
  # @param attribute_names [Symbol, Array<Symbol>] One or more attribute names to mark as containing markup
  # @param options [Hash<Symbol=>Symbol>, Hash<Symbol=>Array<Symbol>>]  Options to be used when rendering this/these attributes
  # @option options [Symbol] :markup The markup engine to use, either +:textile+ or +:markdown+. If you use either of
  #                                  +textile_attribute+ or +markdown_attribute+, wrapper methods, this will be set automatically.
  # @option options [Symbol, Array<Symbol>] :allow Which types of markup to allow (any not included are implicity denied)
  # @option options [Symbol, Array<symbol>] :deny Which types of markup to deny (any not included are implicity allowed)
  def markup_attribute(*attribute_names, **options)
    raise "must define :markup option" unless options[:markup]
    options.deep_symbolize_keys!
    options[:allow] = Array.wrap(options[:allow] || :all).map(&:to_sym)
    options[:deny] = Array.wrap(options[:deny]).map(&:to_sym)
    options.freeze

    attribute_registry_type = get_type_for(options)

    attribute_names.each do |attribute_name|
      if respond_to?(:translates?) && translates? && translated_attribute_names.include?(attribute_name)
        translation_class.attribute attribute_name, attribute_registry_type
      else
        attribute attribute_name, attribute_registry_type
      end
    end
  end

  private

  MARKUP_TYPES_REGISTRY = {}

  def get_type_for(options)
    allow_keys = options[:allow].map { |x| "+#{x}" }
    deny_keys = options[:deny].map { |x| "-#{x}" }
    type_key = [options[:markup],(allow_keys + deny_keys).sort.join].join('=>').to_sym
    MARKUP_TYPES_REGISTRY.fetch(type_key) do
      klass = Class.new(MarkupType) do
        class_eval do
          define_method(:markup_options) do
            options
          end
        end
      end
      ActiveRecord::Type.register(type_key, klass)
      MARKUP_TYPES_REGISTRY[type_key] = klass
      klass
    end
    type_key
  end
end
