# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "openshift_simulator/version"

Gem::Specification.new do |spec|
  spec.name          = "openshift_simulator"
  spec.version       = OpenshiftSimulator::VERSION
  spec.authors       = ["Nick LaMuro"]
  spec.email         = ["nicklamuro@gmail.com"]

  spec.homepage      = "https://github.com/NickLaMuro/openshift_simulator"
  spec.summary       = "Use VCR cassettes to simulate the Openshift API"
  spec.description   = <<-DESC.gsub(/^ {4}/, '')
    A (poorman's) lib and toolchain for emulating the HTTP responses from
    OpenShift, using pre-recorded VCR cassettes for the simulated responses.

    Allows for both capturing of requests from an existing OpenShift cluster, and
    serving those captured requests up from and recorded cassette.
  DESC

  spec.files         = Dir["lib/**/*", "bin/*"]
  spec.bindir        = "bin"
  spec.executables   = Dir["bin/*"].map { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rack", "~> 2.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "vcr", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 1.12"
end
