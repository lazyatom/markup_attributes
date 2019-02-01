$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "markup_attributes/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "markup_attributes"
  spec.version     = MarkupAttributes::VERSION
  spec.authors     = ["James Adam"]
  spec.email       = ["james@lazyatom.com"]
  spec.homepage    = "https://github.com/lazyatom/markup_attributes"
  spec.summary     = "Unobtrustively control markup rendering of ActiveRecord object attributes"
  spec.description = spec.summary
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.test_files = Dir["spec/**/*"]

  spec.add_dependency "rails", "~> 5.2.2"
  spec.add_dependency "RedCloth", "~> 4.3.2"
  spec.add_dependency "rails-html-sanitizer"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "globalize"
  spec.add_development_dependency "globalize-accessors"
  spec.add_development_dependency "yard"
end
