# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'checkmk/hostdetector/config_dsl'
require 'slop'

module CheckMK
  module HostDetector
    class Cli
      def config_default_filenames
        name = self.class.name.downcase.split('::')[0..1].join('_')
        sep  = File::ALT_SEPARATOR || File::SEPARATOR

        package = [
          [File.dirname(__FILE__), '..', '..', '..', 'config', 'config.rb'],
          [ENV['ProgramFiles(x86)'], name, 'config.rb'],
          [ENV['ProgramFiles'],      name, 'config.rb'],
          [ENV['SystemDrive'] || sep, 'usr',          'share', name, 'config.rb'],
          [ENV['SystemDrive'] || sep, 'usr', 'local', 'share', name, 'config.rb'],
        ]

        site = [
          [ENV['ProgramData'], name, 'config.rb'],
          [ENV['SystemDrive'] || sep, 'etc', name, 'config.rb'],
          [ENV['SystemDrive'] || sep, 'etc', name + '.conf'],
          [ENV['SystemDrive'] || sep, 'etc', name.split('_'), 'config.rb'],
          [ENV['SystemDrive'] || sep, 'etc', name.split('_')[0..-2], name.split('_').last + '.conf'],
        ]

        user = [
          [ENV['AppData'], name, 'config.rb'],
          [ENV['AppData'], name + '.conf'],
          [ENV['LocalAppData'], name, 'config.rb'],
          [ENV['LocalAppData'], name + '.conf'],
          [ENV['HOME'], '.config', name, 'config.rb'],
          [ENV['HOME'], '.config', name.split('_'), 'config.rb'],
          [ENV['HOME'], '.config', name.split('_')[0..-2], name.split('_').last + '.conf'],
          [ENV['HOME'], '.config', name + '.conf'],
          [ENV['HOME'], '.' + name, 'config.rb'],
          [ENV['HOME'], '.' + name + '.conf'],
        ]

        filenames = package + site + user
        filenames.select! { |a| a.all? { |e| e } }
        filenames.map! { |a| File.join(a).gsub(File::SEPARATOR, sep) }

        filenames
      end

      def config_load(filenames)
        config = ConfigDSL.new

        filenames.map { |filename|
          File.realpath(filename)
        }.uniq.each do |filename|
          puts "Loading configuration from #{filename}"
          config.load(filename)
        end

        config
      end

      def run(argv = ARGV)
        options = parse_options_slop(argv)
        config  = config_load(Dir.glob(config_default_filenames) +
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
          given order and settings from all files are merged. The following files are
          always tried to read if they exist:
          END
          .gsub(/^          /, '')
        options.banner << "\n  " << config_default_filenames.join("\n  ") << "\n"
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
