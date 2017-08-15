# frozen_string_literal: true

require 'bundler/setup'
Bundler.setup

require 'pry' unless ENV['CI']
require 'webmock/rspec'

require 'qa/ldf'
require 'qa/ldf/spec'

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.color = true
  config.tty = true

  config.formatter = :progress
end
