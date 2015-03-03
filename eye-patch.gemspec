# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "eye/patch/version"

Gem::Specification.new do |spec|
  spec.name          = "eye-patch"
  spec.version       = Eye::Patch::VERSION
  spec.authors       = ["Andrew Horner"]
  spec.email         = ["andrew@tablexi.com"]
  spec.description   = "Easily load your eye configuration from a YAML file."
  spec.summary       = %q[
    Eye::Patch abstracts out the Eye DSL to allow you to load your configuration
    from a structured YAML file, rather than relying on Eye's built-in DSL.
  ]
  spec.homepage      = "https://github.com/tablexi/eye-patch"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ["lib"]

  spec.add_dependency "eye", ">= 0.6.2"
  spec.add_dependency "chronic_duration"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "mocha"
end
