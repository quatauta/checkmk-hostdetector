#!/usr/bin/env ruby

require 'awesome_print'
require 'ipaddr'
require 'pp'


module CheckMK
  module Helper
    module NMAP
      def self.ping(target, options = '')
        self.scan(target, "-n -sP #{options}")
      end

      def self.scan(target, options = '')
        `nmap #{options} #{target} 2>/dev/null`
          .lines
          .reject { |l| l =~ /Starting nmap .*http:\/\/.*nmap/i }
          .join('\n')
      end
    end

    module SNMP
      def self.status(agent, version: '2c', community: 'public')
        `snmpstatus -v#{version} -c#{community} -mALL #{agent} 2>/dev/null`
      end

      def self.bulkget(agent, version: '2c', community: 'public', oids: [])
        `snmpbulkget -v#{version} -c#{community} -mALL #{agent} #{oids.join(' ')} 2>/dev/null`
      end
    end

    def self.map(map, text)
      results = []

      map.each_pair do |regex, value|
        if text =~ regex
          results << value
        end
      end

      results
    end
  end


  class Device
    include Comparable

    TYPE_MAP = {
      /\b10\.9\.[0-9]{3}\.1\b/ => 'router',
      /switch|superstack/i     => 'switch',
    }

    OPERATING_SYSTEM_MAP = {
      /linux/i              => 'linux',
      /microsoft.*windows/i => 'windows',
    }

    MODEL_MAP = {
      /dell.*2900/i => 'dell-2900',
      /dell.*r520/i => 'dell-r520',
      /dell.*r710/i => 'dell-r710',
      /dell.*t420/i => 'dell-t420',
    }

    SERVICE_MAP = {
      /dhcp/i   => 'dhcp',
      /dns/i    => 'dns',
      /http\b/i => 'http', # \b matches word-boundary to avoid matching "https"
      /https/i  => 'https',
      /ldap\b/i => 'ldap', # \b matches word-boundary to avoid matching "ldaps"
      /ldaps/i  => 'ldap',
      /smtp\b/i => 'smtp', # \b matches word-boundary to avoid matching "smtps"
      /smtps/i  => 'smtps',
      /ssh/i    => 'ssh',
    }

    attr_accessor :hostname
    attr_accessor :ipaddress
    attr_accessor :location
    attr_accessor :networking
    attr_accessor :criticality
    attr_accessor :agent
    attr_accessor :type
    attr_accessor :model
    attr_accessor :operatingsystem
    attr_accessor :services

    def initialize(hostname: nil, ipaddress: nil, location: nil)
      self.hostname  = hostname
      self.ipaddress = ipaddress
      self.location  = location
    end

    def name
      if !self.hostname.to_s.empty?
        self.hostname
      else
        # TODO Build a symbolic name out of ipaddress
        self.ipaddress
      end
    end

    def <=>(other)
      self.to_s <=> other.to_s
    end

    def to_s
      self.name.to_s
    end

    def detect_properties!
      snmp_oids = %w[sysDescr sysObjectID]
      snmp_version = nil
      status = ''

      ['2c', '1'].each do |version|
        if status.empty?
          status = Helper::SNMP.status(self.ipaddress.to_s, version: version)
          snmp_version = version unless status.empty?
        end
      end

      status << Helper::SNMP.bulkget(self.ipaddress.to_s,
                                     version: snmp_version,
                                     oids: snmp_oids) if snmp_version
      status << Helper::NMAP.scan(self.ipaddress.to_s, '-O')

      self.networking      = 'lan'
      self.criticality     = 'prod'
      self.agent           = 'ping'    unless snmp_version
      self.agent           = 'snmp'    if snmp_version == '2c'
      self.agent           = 'snmp-v1' if snmp_version == '1'
      self.type            = Helper.map(TYPE_MAP, status).first
      self.model           = Helper.map(MODEL_MAP, status).first
      self.operatingsystem = Helper.map(OPERATING_SYSTEM_MAP, status).first
      self.services        = Helper.map(SERVICE_MAP, status)

      self
    end
  end


  class Location
    include Comparable

    attr_accessor :name, :ranges, :devices

    def initialize(name, ranges: [])
      self.name   = name
      self.ranges = ranges
    end

    def <=>(other)
      self.name <=> other.name
    end

    def detect!
      self.devices = Location::detect(self.ranges)

      self.devices.each { |d| d.location = self }

      self
    end

    def self.detect(ranges = [])
      devices = []

      Helper::NMAP.ping(ranges.join(' '), '-oG -').lines.select { |l| l =~ /host.*status.*up/i }.each do |line|
        tmp_a, ipaddress, hostname, *tmp_b = line.split

        hostname.gsub!(/[()]/, '')

        hostname  = nil if hostname.empty?
        ipaddress = IPAddr.new(ipaddress)
        device    = Device.new(hostname:  hostname, ipaddress: ipaddress)

        devices.push(device)
      end

      devices
    end
  end


  class Detector
    attr_accessor :locations

    def detect_devices!
      ## TODO Run detection in threads
      self.locations.each do |location|
        location.detect!
      end

      self
    end

    def detect_device_properties!
      ## TODO Run detection in threads
      self.locations.each do |location|
        location.devices.each do |device|
          device.detect_properties!
        end
      end
    end

    def parse_locations(text = "")
      self.locations = Detector::parse_locations(text)
      self
    end

    def self.parse_locations(text = "")
      locations = []

      text.each_line do |line|
        name, *ranges = line.split

        locations.push(Location.new(name, ranges: ranges))
      end

      locations
    end
  end
end


if __FILE__ == $0
  detector = CheckMK::Detector.new

  detector.parse_locations(ARGF.read)
  detector.detect_devices!
  detector.detect_device_properties!

  detector.locations.each do |location|
    puts "#{location.name}: #{location.ranges.join(" ")}, #{location.devices.size} devices"

    location.devices.each do |device|
      puts "  #{device.name}"
      puts "    hostname:        #{device.hostname}"
      puts "    ipaddress:       #{device.ipaddress}"
      puts "    location:        #{device.location.name}"
      puts "    networking:      #{device.networking}"
      puts "    criticality:     #{device.criticality}"
      puts "    agent:           #{device.agent}"
      puts "    type:            #{device.type}"
      puts "    model:           #{device.model}"
      puts "    operatingsystem: #{device.operatingsystem}"
      puts "    services:        #{device.services}"
    end
  end
end
