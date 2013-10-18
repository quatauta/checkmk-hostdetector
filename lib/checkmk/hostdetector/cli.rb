# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'checkmk/hostdetector/config_dsl'
require 'slop'

module CheckMK
  module HostDetector
    class Cli
      def default_config_dirs
        sep = File::ALT_SEPARATOR || File::SEPARATOR

        [
          # possible distribution install dirs
          [sep, 'usr', 'share'],
          [sep, 'usr', 'local', 'share'],
          [ENV['ProgramFiles']],
          [ENV['ProgramFiles(x86)']],
          # possible distribution system config dirs
          [sep, 'etc'],
          [ENV['ProgramData']],
          # possible user config dirs
          [ENV['HOME'], '.config'],
          [ENV['AppData']],
          [ENV['LocalAppData']],
        ]
      end

      def default_config_filename_variants
        name = self.class.name.downcase.split('::')[0..1].join('_')
        name_parts = name.split('_')

        [
          [name, 'config.rb'],
          [name + '.conf'],
          [name_parts, 'config.rb'],
          [name_parts[0..-2], name_parts.last + '.conf'],
        ]
      end

      def default_config_filenames
        sep = File::ALT_SEPARATOR || File::SEPARATOR

        filenames = [[File.dirname(__FILE__), '..', '..', '..', 'config', 'config.rb']]
        filenames = filenames + (default_config_dirs.product(default_config_filename_variants))
        filenames.map! { |ary| ary.flatten }
        filenames.select! { |ary| ary.all? { |elem| elem } }
        filenames.map! { |ary| File.join(ary) }
        filenames.map! { |fn| fn.gsub(File::SEPARATOR, sep) } if File::SEPARATOR != sep
        filenames.map! { |fn| begin ; File.realpath(fn) ; rescue Errno::ENOENT ; fn ; end }

        filenames
      end

      def config_load(filenames)
        config = ConfigDSL.new

        filenames.map { |filename|
          File.realpath(filename)
        }.uniq.each do |filename|
          puts "Loading configuration from #{filename}"
          config.load_file(filename)
        end

        config
      end

      def run(argv = ARGV)
        options = parse_options_slop(argv)
        config  = config_load(Dir.glob(default_config_filenames) +
                              options[:config])

        # detector = Detector.new(config)
        # wato     = WatoOutput.new(config)
        #
        # detector.parse_sites(options[:sites])
        # detector.detect_hosts
        # detector.detect_hosts_properties
        #
        # detector.sites.each do |site|
        #   puts "#{site.name} #{site.ranges.join(" ")}: #{site.hosts.size} hosts"
        #   site.hosts.each do |host|
        #     puts "  #{host.name}"
        #     puts "    hostname:  #{host.hostname}"
        #     puts "    ipaddress: #{host.ipaddress}"
        #     puts "    site:      #{host.site.name}"
        #     puts "    tags:      " + host.tags.to_h.to_a.map { |a| a[0].to_s == a[1].to_s ? a[0].to_s : "#{a[0]}:#{a[1]}" }.sort.join(' ')
        #   end
        #   puts
        #   puts "WATO hosts.mk for site #{site.name}"
        #   puts "-----------------------------------"
        #   puts wato.hosts_mk(site.hosts)
        #   puts
      end

      def parse_options_slop(argv = ARGV)
        options = Slop.new help: true, multiple_switches: true

        options.banner <<-END
          Scans your network for hosts and builds suitable configuration for
          CheckMK/WATO.

          Usage:
            #{$PROGRAM_NAME} [OPTIONS] [-s SITES-FILE...] [SITE-FILES...]

          STDIN is read if site file is '-' or omitted:
            #{$PROGRAM_NAME} [OPTIONS] [-s -] [-] < SITES-FILE
            cat SITES-FILES... | #{$PROGRAM_NAME} [OPTIONS] [-]
            echo 'Local 192.168.0.0/24' | #{$PROGRAM_NAME} [OPTIONS] [-]

          Site files contain a name and the IP adress ranges to be scanned. Each line
          begins with the site's name followed by one or multiple IP address ranges. Name
          and range(s) are divided by whitespace. The ranges must conform to the nmap [1]
          target specifications. Multiple lines the contain the same site's name are
          merged.

            Site-A 10.0.1.0/24 10.0.100.0/24
            Site-A 192.168.0,1,2.1-254
            Site-B 10.0.2.0/24 10.0.200.0/24
            Site-C 10.0.3.0/24 10.0.300.0/24

          [1] http://nmap.org/book/man-target-specification.html

          The options listed below may be specified in different ways like shown in this
          examples:  -ca.rb  -c a.rb  -c=a.rb  --c a.rb  --c=a.rb
                     -config a.rb  -config=a.rb  --config a.rb  --config=a.rb

          You can specify more than one configuration file. The files are read in the
          given order and settings from all files are merged.
          END
          .gsub(/^          /, '')
        options.banner << "\n"
        options.banner << "Options:"

        options.on('c=', 'config', 'The configuration file(s) to use.', as: Array, default: [])
        options.on('j=', 'jobs', 'The maximum number of jobs to run in parallel', as: Integer, default: 4)
        options.on('s=', 'sites', 'The file containing sites/ranges to be scanned', as: Array, default: [])

        options.parse(argv)
        options
      end
    end
  end
end
