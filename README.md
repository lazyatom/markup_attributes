# MarkupAttributes
A simple Rails engine for cleanly handling Textile/Markdown markup in ActiveRecord attributes.

Using this engine, we can define a particular attribute as containing markup, with constraints around
which markup rules and tags we want to support, and then render that attribute value to HTML
consistently throughout the rest of the application.

Rather than adding any HTML generation into the model itself, this works by attaching metadata
to the model, which can then be consumed by a helper when the attribute is used in views.

In the future, this will expand to also handle Markdown, Github-Flavoured Markdown and potentially
any other markup language; the underlying mechanism is markup-agnostic, and others can easily
be added.

## Usage
Once you've added this gem to your application, you can enable it on a per-model basis by
extending the model class with the {#MarkupAttributes} module, and then declaring one or more
attributes as having textile:

    class Post < ApplicationRecord
      extend MarkupAttributes
      
      textile_attribute :title, :description
    end
    
You can then deal with the model as with any other ActiveRecord subclass; the attributes
can be treated as simple strings:

    post = Post.create(title: 'My _cool_ post', description: 'A post about *stuff*')
    post.title # => 'My _cool_ post'
    post.description # => 'A post about *stuff*'

When you want to render the markup in a view, use the `render_markup` helper method:

    <h1><%= render_markup post.title %></h1>
    <p><%= render_markup post.description %></p>

which will produce the HTML

    <h1>My <em>cool</em> post</h1>
    <p>A post about <strong>stuff</strong></p>


### Markup constraints

The main benefit of this gem is that it allows you to define _constraints_ about what markup
an attribute should support in a single place, and have those rules be applied consistently
wherever the content is rendered. We do this using the `:allow` and `:deny` options to
`textile_attribute`.

    class Post < ApplicationRecord
      extend MarkupAttributes
      
      textile_attribute :title, allow: :emphasis
    end

If any `:allow` options are set, anything missing from that option is assumed to be denied, and
will be removed from the rendered markup. So, anywhere we try to render the title markup now,
these rules will be respected:

    <% post = Post.new(title: '"Link":http://example.com this _up_') %>
    <%= render_markup post.title %>

produces

    Link this <em>up</em>

Because we didn't allow links, that aspect of the markup is removed.

We can include multiple allowed markup types:

    textile_attribute :title, allow: [:emphasis, :links, :images]

or, we can allow all markup and then explicitly deny certain types:

    textile_attribute :title, deny: :images


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'markup_attributes'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install markup_attributes
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
