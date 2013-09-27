#!/usr/bin/env ruby
# -*- coding: utf-8-unix; mode: ruby; -*-
# vim:set fileencoding=UTF-8 syntax=ruby:

require 'checkmk/devicedetector'

CheckMK::DeviceDetector::Config.load

detector = CheckMK::DeviceDetector::Detector.new

detector.parse_locations(ARGF.read)
detector.detect_devices(CheckMK::DeviceDetector::Config.jobs)
detector.detect_devices_properties(CheckMK::DeviceDetector::Config.jobs)

detector.locations.each do |location|
  puts "#{location.name} #{location.ranges.join(" ")}: #{location.devices.size} devices"

  location.devices.each do |device|
    puts "  #{device.name}"
    puts "    hostname:  #{device.hostname}"
    puts "    ipaddress: #{device.ipaddress}"
    puts "    location:  #{device.location.name}"
    puts "    tags:      " + device.tags.to_h.to_a.map { |a| a[0].to_s == a[1].to_s ? a[0].to_s : "#{a[0]}:#{a[1]}" }.sort.join(' ')
  end
end
