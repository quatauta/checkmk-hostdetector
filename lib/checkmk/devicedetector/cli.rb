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

        detector.parse_sites(ARGF.read)
        detector.detect_devices(CheckMK::DeviceDetector::Config.jobs)
        detector.detect_devices_properties(CheckMK::DeviceDetector::Config.jobs)

        detector.sites.each do |site|
          puts "#{site.name} #{site.ranges.join(" ")}: #{site.devices.size} devices"
          site.devices.each do |device|
            puts "  #{device.name}"
            puts "    hostname:  #{device.hostname}"
            puts "    ipaddress: #{device.ipaddress}"
            puts "    site:      #{device.site.name}"
            puts "    tags:      " + device.tags.to_h.to_a.map { |a| a[0].to_s == a[1].to_s ? a[0].to_s : "#{a[0]}:#{a[1]}" }.sort.join(' ')
          end
        end
      end

      def parse_options_slop(argv = ARGV)
        options = Slop.new help: true, multiple_switches: true

        options.banner <<-END
          Scans your network for devices and builds suitable configuration for
          CheckMK/WATO.

          Usage:
            #{$PROGRAM_NAME} [OPTIONS] [-l] SITE-FILES

          STDIN is read if site file is '-' or omitted:
            #{$PROGRAM_NAME} [OPTIONS] < SITES-FILE
            cat SITES-FILES | #{$PROGRAM_NAME} [OPTIONS] [-r -]
            echo 'Local 192.168.0.0/24' | #{$PROGRAM_NAME} [OPTIONS] [-r -]

          Site files contain a name and the IP adress ranges to be scanned. Each line
          begins with the site's name followed by one or multiple IP address ranges. Name
          and range(s) are divided by whitespace. The ranges must conform to the nmap [1]
          target specifications.

            Site-A 10.0.1.0/24 10.0.100.0/24 192.168.0,1,2.1-254
            Site-B 10.0.2.0/24 10.0.200.0/24
            Site-C 10.0.3.0/24 10.0.300.0/24

          [1] http://nmap.org/book/man-target-specification.html

          The options listed below may be specified indifferent ways like shown in this
          examples:  -ca.rb  -c a.rb  -c=a.rb  --c a.rb  --c=a.rb
                     -config a.rb  -config=a.rb  --config a.rb  --config=a.rb
          END
          .gsub(/^          /, '')
        options.on('c=', 'config=', 'The configuration file(s) to use',
                   as: Array, default: ['config.rb'])
        options.on('j=', 'jobs=', 'The maximum number of jobs run in parallel',
                   as: Integer, default: 4)
        options.on('s=', 'sites=', 'The file(s) containing sites to be scanned',
                   as: Array, default: ['sites.txt'])

        options.parse(argv)
        options
      end
    end
  end
end
