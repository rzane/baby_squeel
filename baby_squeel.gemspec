# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'baby_squeel/version'

Gem::Specification.new do |spec|
  spec.name          = 'baby_squeel'
  spec.version       = BabySqueel::VERSION
  spec.authors       = ['Ray Zane']
  spec.email         = ['ray@promptworks.com']

  spec.summary       = 'An expressive query DSL for Active Record 4 and 5.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/rzane/baby_squeel'
  spec.license       = 'MIT'

  spec.bindir        = 'exe'
  spec.require_paths = ['lib']

  spec.files = Dir.glob('{lib/**/*,*.{md,txt,gemspec}}')

  spec.add_dependency 'activerecord', '>= 4.2.0'
  spec.add_dependency 'polyamorous', '~> 1.3'
  spec.add_dependency 'join_dependency', '~> 0.1.2'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4.0'
  spec.add_development_dependency 'sqlite3', '~> 1.3.13' # see https://github.com/rails/rails/issues/35153
end
