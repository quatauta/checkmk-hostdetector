# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

module CheckMK
  module HostDetector
    autoload :Cli,           'checkmk/hostdetector/cli'
    autoload :ConfigDSL,     'checkmk/hostdetector/config_dsl'
    autoload :Detector,      'checkmk/hostdetector/detector'
    autoload :Helper,        'checkmk/hostdetector/helper'
    autoload :Host,          'checkmk/hostdetector/host'
    autoload :Site,          'checkmk/hostdetector/site'
    autoload :VERSION,       'checkmk/hostdetector/version'
    autoload :WatoOutput,    'checkmk/hostdetector/watooutput'
  end
end
