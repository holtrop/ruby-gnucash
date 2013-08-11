require "bundler/gem_tasks"
require "rake/clean"
require "rspec/core/rake_task"
require "rdoc/task"
require "yard"

CLEAN.include "doc"

YARD::Rake::YardocTask.new do |yard|
  yard.files = ['lib/**/*.rb']
end

RSpec::Core::RakeTask.new("spec")

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Ruby library for extracting data from GnuCash data files"
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :spec
