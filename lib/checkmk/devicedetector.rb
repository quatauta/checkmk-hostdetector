# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

module CheckMK
  module DeviceDetector
    autoload :Cli,           'checkmk/devicedetector/cli'
    autoload :Config,        'checkmk/devicedetector/config'
    autoload :Configuration, 'checkmk/devicedetector/configuration'
    autoload :Detector,      'checkmk/devicedetector/detector'
    autoload :Device,        'checkmk/devicedetector/device'
    autoload :Helper,        'checkmk/devicedetector/helper'
    autoload :Site,          'checkmk/devicedetector/site'
    autoload :VERSION,       'checkmk/devicedetector/version'
  end
end
