# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'baby_squeel/version'

Gem::Specification.new do |spec|
  spec.name          = 'baby_squeel'
  spec.version       = BabySqueel::VERSION
  spec.authors       = ['Ray Zane']
  spec.email         = ['ray@promptworks.com']

  spec.summary       = 'An expressive query DSL for Active Record 7.1+'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/rzane/baby_squeel'
  spec.license       = 'MIT'

  spec.bindir        = 'exe'
  spec.require_paths = ['lib']

  spec.files = Dir.glob('{lib/**/*,*.{md,txt,gemspec}}')

  spec.add_dependency 'activerecord', '>= 7.1.5', '< 8.1'
  spec.add_dependency 'ransack', '~> 4.1'

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'sqlite3'
end
