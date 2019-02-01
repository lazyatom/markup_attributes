begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'yard'
YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['app/**/*.rb', 'lib/**/*.rb', '-', 'README.md']
  t.options = ['--no-private']
end

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load 'rails/tasks/engine.rake'

load 'rails/tasks/statistics.rake'

require 'bundler/gem_tasks'

if defined? RSpec
  task(:spec).clear
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.verbose = false
  end
end

task default: :spec
