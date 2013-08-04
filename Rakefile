require "bundler/gem_tasks"
require "rake/clean"
require "yard"

CLEAN.include "doc"

YARD::Rake::YardocTask.new do |yard|
  yard.files = ['lib/**/*.rb']
end
