require "bundler/gem_tasks"
require "rake/testtask"

task default: :test
task spec: :test

# Run specs
Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end
