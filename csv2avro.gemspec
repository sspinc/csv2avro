# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csv2avro/version'

Gem::Specification.new do |spec|
  spec.name          = "csv2avro"
  spec.version       = CSV2Avro::VERSION
  spec.authors       = ["Peter Ableda", "Peter Marton"]
  spec.email         = ["scotty@secretsaucepartners.com", "martonpe@secretsaucepartners.com"]
  spec.summary       = %q{Convert CSV files to Avro}
  spec.description   = %q{Convert CSV files to Avro like a boss.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "bump", "~> 0.5"
  spec.add_development_dependency "byebug"

  spec.add_runtime_dependency "avro", "~> 1.7"
end
