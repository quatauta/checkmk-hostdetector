# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'checkmk/hostdetector/config_dsl'
require 'slop'

module CheckMK
  module HostDetector
    class Cli
      HELP = <<-END.gsub(/^ {8}/, '')
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

        Options:
      END

      OPTIONS = [
        { short: 'c', long: 'config', desc: 'Configuration file(s) to use',          type: Array,   default: [], },
        { short: 'j', long: 'jobs',   desc: 'Number of jobs to run in parallel',     type: Integer, default: nil, },
        { short: 's', long: 'sites',  desc: 'Files containing sites/ranges to scan', type: Array,   default: [], },
      ]

      def run(argv = ARGV)
        options = Cli.parse_options_slop(HELP, OPTIONS, argv)
        config  = Cli.load_config(Dir.glob(Cli.default_config_filenames) +
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

      def self.default_config_dirs
        [
          [File.dirname(__FILE__), '..', '..', '..', 'config'],
          [File::SEPARATOR, 'usr', 'share'],
          [File::SEPARATOR, 'usr', 'local', 'share'],
          [File::SEPARATOR, 'etc'],
          [ENV['HOME'], '.config'],
        ].map { |ary| File.join(ary) }
      end

      def self.default_config_filename_variants
        module_name = Module.nesting[1].name
        name_parts  = module_name.downcase.split('::')
        name        = name_parts.join('_')

        [
          [name, 'config.rb'],
          [name + '.conf'],
          [name_parts, 'config.rb'],
          [name_parts[0..-2], name_parts.last + '.conf'],
        ].map { |ary| File.join(ary) }
      end

      def self.default_config_filenames
        dirs      = default_config_dirs
        variants  = default_config_filename_variants

        dirs.product(variants).map { |ary|
          fn = File.join(ary)
          File.exist?(fn) ? File.realpath(fn) : fn
        }
      end

      def self.load_config(filenames)
        config = ConfigDSL.new

        filenames.map { |filename|
          File.realpath(filename)
        }.uniq.each do |filename|
          puts "Loading configuration from #{filename}"
          config.load_file(filename)
        end

        config
      end

      def self.option_parser_slop(help, options)
        slop = Slop.new(help: true, multiple_switches: true)
        slop.banner = help

        options.each do |opt|
          args = {}
          args[:as]      = opt[:type]    if opt[:type]
          args[:default] = opt[:default] if opt[:default]
          slop.on(opt[:short], opt[:long] + (opt[:type] ? '=' : ''), opt[:desc], args)
        end

        slop
      end

      def self.parse_options_slop(help, options, argv)
        slop = option_parser_slop(help, options)
        slop.parse(argv)
        slop
      end
    end
  end
end
