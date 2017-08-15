#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |spec|
  spec.authors       = ['Tom Johnson']
  spec.email         = ['tom@curationexperts.com']

  spec.name          = 'qa-ldf'
  spec.homepage      = 'http://github.com/curationexperts/qa-ldf'
  spec.description   = 'Questioning Authority cached with a Linked Data ' \
                       'Fragment.'
  spec.summary       = 'Provides a bridge between questioning authority and ' \
                       'a caching linked data fragment for URI authorities.'

  spec.version       = File.read('VERSION').chomp
  spec.date          = File.mtime('VERSION').strftime('%Y-%m-%d')
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.required_ruby_version = '>= 2.2.2'

  spec.add_dependency 'rdf', '>= 2.0', '< 2.2.4'
  spec.add_dependency 'qa',  '~> 1.0'

  spec.add_development_dependency 'active-fedora',     '~> 11.0'
  spec.add_development_dependency 'guard',             '~> 2.14'
  spec.add_development_dependency 'ld_cache_fragment', '~> 0.1'
  spec.add_development_dependency 'rake',              '~> 12.0'
  spec.add_development_dependency 'rspec',             '~> 3.5'
  spec.add_development_dependency 'rubocop-rspec',     '1.10.0'
  spec.add_development_dependency 'sham_rack',         '~> 1.4'
  spec.add_development_dependency 'webmock',           '~> 2.3', '>= 2.3.2'
  spec.add_development_dependency 'yard',              '~> 0'
end
