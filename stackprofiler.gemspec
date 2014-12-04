# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stackprofiler/version'

Gem::Specification.new do |spec|
  spec.name          = 'stackprofiler'
  spec.version       = Stackprofiler::VERSION
  spec.authors       = ['Aidan Steele']
  spec.email         = ['aidan.steele@glassechidna.com.au']
  spec.summary       = %q{Web UI wrapper for the awesome stackprof profiler.}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'stackprof'
  spec.add_dependency 'rubytree'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'sinatra-contrib'
  spec.add_dependency 'coderay'
  spec.add_dependency 'oj'
end
