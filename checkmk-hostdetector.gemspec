# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'checkmk/hostdetector/version'

Gem::Specification.new do |spec|
  spec.name          = "checkmk-hostdetector"
  spec.version       = CheckMK::HostDetector::VERSION
  spec.authors       = ["Daniel Schömer"]
  spec.email         = ["daniel.schoemer@gmx.net"]
  spec.description   = %q{Build CheckMK/Multisite/WATO configuration files for networking hosts. Hosts are found with nmap. Host properties like vendor/product and offered services are detected using nmap and net-snmp.}
  spec.summary       = %q{CheckMK/Multisite/WATO configuration for networking hosts using on nmap/net-snmp}
  spec.homepage      = "https://github.com/quatauta/#{spec.name}"
  spec.licenses      = ["MIT"]

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "bundler-audit"
  spec.add_development_dependency "fuubar"
  spec.add_development_dependency "metric_fu"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rdoc"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubinjam"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "yard"

  spec.add_runtime_dependency 'progressbar', ['>= 0.21.0']
  spec.add_runtime_dependency 'docopt', ['>= 0.5']
  spec.add_runtime_dependency 'thread', ['>= 0.1.1']
end
