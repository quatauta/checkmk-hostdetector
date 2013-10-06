# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

module CheckMK::HostDetector
  autoload :Cli,           'checkmk/hostdetector/cli'
  autoload :Config,        'checkmk/hostdetector/config'
  autoload :Configuration, 'checkmk/hostdetector/configuration'
  autoload :Detector,      'checkmk/hostdetector/detector'
  autoload :Helper,        'checkmk/hostdetector/helper'
  autoload :Host,          'checkmk/hostdetector/host'
  autoload :Site,          'checkmk/hostdetector/site'
  autoload :VERSION,       'checkmk/hostdetector/version'
end
