#!/usr/bin/env rake
require 'yard'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
end

RSpec::Core::RakeTask.new(:spec)

desc 'Build YARD documentation'
YARD::Rake::YardocTask.new do |t|
  t.files         = ['lib/**/*.rb', 'LICENSE.md']
  t.stats_options = ['--list-undoc']
end

desc 'Run continious integration'
task ci: %i[rubocop spec]

task default: :ci
