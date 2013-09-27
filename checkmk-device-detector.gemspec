# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'checkmk/devicedetector/version'

Gem::Specification.new do |spec|
  spec.name          = "checkmk-device-detector"
  spec.version       = Checkmk::DeviceDetector::VERSION
  spec.authors       = ["Daniel Schömer"]
  spec.email         = ["daniel.schoemer@gmx.net"]
  spec.description   = %q{Build CheckMK/Multisite/WATO configuration files for networking devices. Devices are found with nmap. Device properties like vendor/product and offered services are detected using nmap and net-snmp.}
  spec.summary       = %q{CheckMK/Multisite/WATO configuration for networking devices using on nmap/net-snmp}
  spec.homepage      = "https://github.com/quatauta/#{spec.name}"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency 'progressbar', ['>= 0.21.0']
  spec.add_runtime_dependency 'thread', ['>= 0.1.1']
end
