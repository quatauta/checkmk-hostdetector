# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'checkmk/devicedetector'
require 'slop'

module CheckMK
  module DeviceDetector
    class Cli
      def run(argv = ARGV)
        parse_options_slop(argv)

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
      end

      def parse_options_slop(argv = ARGV)
        options = Slop.new :help => true, :multiple_switches => true

        options.banner \
          "Scans your network for devices and builds suitable configuration for CheckMK/WATO." + "\n\n" +
          "Usage:" + "\n" +
          "  #{$PROGRAM_NAME} [-c CONFIG-FILE] [-j JOBS] [-l LOCATIONS-FILE]" + "\n" +
          "  #{$PROGRAM_NAME} [-c CONFIG-FILE] [-j JOBS] <LOCATIONS-FILE"     + "\n" +
          "  echo 'Local 192.168.0.0/24' | #{$PROGRAM_NAME} [-c CONFIG-FILE] [-j JOBS]" + "\n"

        options.on('c=', 'config=', 'The configuration file to use',
                   :default => 'config.rb')
        options.on('j=', 'jobs=', 'The maximum number of jobs run in parallel',
                   :as => Integer, :default => 4)
        options.on('l=', 'locations=', 'The file(s) containing a list of locations to be scanned',
                   :as => Array, :default => ['locations.txt'])

        options.parse(argv)
        options
      end
    end
  end
end
