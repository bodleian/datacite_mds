# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datacite_mds/version'

Gem::Specification.new do |spec|
  spec.name          = "datacite_mds"
  spec.version       = DataciteMds::VERSION
  spec.authors       = ["Fred Heath", "Michael Davis"]
  spec.email         = ["michael.davis@bodleian.ox.ac.uk"]

  spec.summary       = %q{This gem allows for Ruby client connectivity to Datacite's Metadata Store (https://mds.datacite.org/)}
  spec.description   = %q{The MDS is a service for data publishers to mint DOIs and register associated metadata. It is aimed mainly at scientific and research data publishers. This gem allows for simple and seamless interaction with this service.}
  spec.homepage      = "https://github.com/bodleian/datacite_mds"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "travis"
  spec.add_development_dependency "coveralls"

  spec.add_dependency "nokogiri", "~> 1.6"

end
