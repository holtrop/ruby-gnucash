require "bundler"
begin
    Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
    raise LoadError.new("Unable to Bundler.setup(): You probably need to run `bundle install`: #{e.message}")
end
require "bundler/gem_tasks"
require "rake/clean"
require "rspec/core/rake_task"
require "yard"

CLEAN.include "doc"
CLEAN.include "pkg"
CLEAN.include "coverage"

YARD::Rake::YardocTask.new do |yard|
  yard.files = ['lib/**/*.rb']
end

RSpec::Core::RakeTask.new("spec")

YARD::Rake::YardocTask.new(:yard)

task :default => :spec
