# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "csv2avro"
  spec.version       = "0.1.0"
  spec.authors       = ["Peter Ableda"]
  spec.email         = ["scotty@secretsaucepartners.com"]
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
  spec.add_development_dependency "bump"

  spec.add_dependency "aws-sdk", "~> 2"
  spec.add_dependency "avro", "~> 1.7"
end
