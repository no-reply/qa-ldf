# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'pry' unless ENV['CI']

gem 'ld_cache_fragment',
    github: 'ActiveTriples/linked-data-fragments',
    branch: 'feature/multi-dataset'
