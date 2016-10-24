# -*- coding: utf-8; -*-
# frozen_string_literal: true
# vim:set fileencoding=utf-8:

require 'checkmk/hostdetector/config_dsl'
require 'checkmk/hostdetector/version'
require 'contracts'
require 'docopt'

module CheckMK
  module HostDetector
    class Cli
      include Contracts

      HELP = <<-END.gsub(/^ {8}/, '')
        Scans your network for hosts and builds suitable configuration for CheckMK/WATO.

        Usage:
          #{$PROGRAM_NAME} [ [options] | SITE ]...

        Options:
          -c CONF, --config=CONF  Configuration files to use
          -j JOBS, --jobs=JOBS    Number of jobs to run in parallel
          -s SITE, --site=SITE    Files containing sites/ranges to scan
          -h, --help              Show this description
          -v, --version           Show version and exit

        STDIN is read if SITE is '-' or omitted.

        Site files contain a name and the IP adress ranges to be scanned. Each line begins
        with the site's name followed by one or multiple IP address ranges. Name and
        range(s) are divided by whitespace. The ranges must conform to the nmap [1] target
        specifications. Multiple lines containg the same site name are merged.

          Site-A 10.0.1.0/24 10.0.100.0/24
          Site-A 192.168.0,1,2.1-254
          Site-B 10.0.2.0/24 10.0.200.0/24
          Site-C 10.0.3.0/24 10.0.300.0/24

        [1] http://nmap.org/book/man-target-specification.html

        You can specify more than one configuration file. The files are read in the given
        order and settings from all files are merged.
      END

      Contract ArrayOf[String] => None
      def run(argv = ARGV)
        begin
          options = Cli.parse_options_docopt(HELP, argv.dup,
                                             "%s %s" % [
                                               $PROGRAM_NAME,
                                               CheckMK::HostDetector::VERSION
                                             ])
        rescue Docopt::Exit => e
          puts e.message
          exit
        end

        require 'pp'
        pp options: options

        config = Cli.load_config(Dir.glob(Cli.default_config_filenames) +
                                 options[:config])
        options[:jobs].map { |str|
          str.to_i
        }.reject { |int|
          0 == int
        }.each do |jobs|
          config.jobs(jobs)
        end

        options[:site].each do |filename|
          File.read(filename).each_line do |line|
            config.site(*line.split)
          end
        end

        pp config: config

        # TODO: settle cli

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

      Contract None => ArrayOf[String]
      def self.default_config_dirs
        [
          [__dir__, '..', '..', '..', 'config'],
          [File::SEPARATOR, 'usr', 'share'],
          [File::SEPARATOR, 'usr', 'local', 'share'],
          [File::SEPARATOR, 'etc'],
          [ENV['HOME'], '.config'],
          [Dir.pwd, 'config'],
          [Dir.pwd],
        ].map { |ary| File.join(ary) }
      end

      Contract None => ArrayOf[String]
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

      Contract None => ArrayOf[String]
      def self.default_config_filenames
        dirs      = default_config_dirs
        variants  = default_config_filename_variants

        dirs.product(variants).map { |ary|
          fn = File.join(ary)
          File.exist?(fn) ? File.realpath(fn) : fn
        }
      end

      Contract ArrayOf[String] => ConfigDSL
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

      Contract String, ArrayOf[String], String => Hash
      def self.parse_options_docopt(help, argv, version)
        options = Docopt::docopt(help, argv: argv, version: version)
        normalize_options(options)
      end

      Contract HashOf[String, Any] => HashOf[Symbol, Any]
      def self.normalize_options(options = {})
        normalized = {}

        options.each_pair do |key, values|
          norm_key = normalize_option_name(key)
          (normalized[norm_key] ||= []).push(*values)
        end

        normalized
      end

      # Normalize the option names created by docopt. To normalize, the name is changed to
      # lower case, leading dashes are removed and names enclosed in '<' '>' are no longer
      # enclosed.
      Contract String => Symbol
      def self.normalize_option_name(name)
        name.sub(/<(.*)>/, '\1')
            .sub(/^--?/, '')
            .downcase
            .to_sym
      end
    end
  end
end
