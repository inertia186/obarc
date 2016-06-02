# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'obarc/version'

Gem::Specification.new do |spec|
  spec.name = 'obarc'
  spec.version = OBarc::VERSION
  spec.authors = ['Anthony Martin']
  spec.email = ['obarc@martin-studio.com']

  spec.summary = %q{OpenBazaar API Ruby Client}
  spec.description = %q{Client for accessing an OpenBazaar server.}
  spec.homepage = 'https://github.com/inertia186/obarc'
  spec.license = 'CC0 1.0'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test)/}) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 11.1.2'
  spec.add_development_dependency 'minitest', '~> 5.9.0'
  spec.add_development_dependency 'webmock', '~> 2.0.3'
  spec.add_development_dependency 'simplecov', '~> 0.11.2'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.5.0'
  spec.add_development_dependency 'yard', '~> 0.8.7.6'
  spec.add_development_dependency 'pry', '~> 0.10.3'
  
  spec.add_dependency('rest-client', '~> 1.8.0')
end
