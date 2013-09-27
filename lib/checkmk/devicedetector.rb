# -*- coding: utf-8-unix; mode: ruby; -*-
# vim:set fileencoding=UTF-8 syntax=ruby:

module CheckMK
  module DeviceDetector
    autoload :Config,   'checkmk/devicedetector/config'
    autoload :Detector, 'checkmk/devicedetector/detector'
    autoload :Device,   'checkmk/devicedetector/device'
    autoload :Helper,   'checkmk/devicedetector/helper'
    autoload :Location, 'checkmk/devicedetector/location'
  end
end
