#!/usr/bin/env ruby
# vim:fileencoding=UTF-8 shiftwidth=2:

require 'ipaddr'
require 'pp'


module CheckMK
  module Helper
    module NMAP
      def self.ping(target, options = '')
        self.scan(target, "-sP #{options}")
      end

      def self.scan(target, options = '')
        puts "nmap"
        `nmap #{options} #{target}`
          .lines
          .reject { |l| l =~ /Starting nmap .*http:\/\/.*nmap/i }
          .join('\n')
      end
    end

    module SNMP
      def self.status(agent, version: '2c', community: 'public')
        puts "snmpstatus"
        `snmpstatus -v#{version} -c#{community} -mALL #{agent}`
      end

      def self.bulkget(agent, version: '2c', community: 'public', oids: [])
        puts "snmpbulkget"
        `snmpbulkget -v#{version} -c#{community} -mALL #{agent} #{oids.join(' ')}`
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
  end


  class Detector
    SNMP_STATUS_OIDS = [
      'sysDescr',
      'sysObjectID',
      'MIB-Dell-CM::dell.10892.1.300.10.1.9',
      'SNMPv2-SMI::enterprises.231.2.10.2.2.5.10.3.1.4',
    ]

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
      /http\b/i => 'http',
      /https/i  => 'https',
      /ldap\b/i => 'ldap',
      /ldaps/i  => 'ldap',
      /smtp\b/i => 'smtp',
      /smtps/i  => 'smtps',
      /ssh/i    => 'ssh',
    }

    attr_accessor :locations

    def detect_devices!
      ## TODO Run detection in threads
      self.locations.each do |location|
        Detector.detect_devices(location)
      end

      self
    end

    def self.detect_devices(location)
      devices = []

      Helper::NMAP.ping(location.ranges.join(' '), '-oG -')
        .lines
        .select {
          |l| l =~ /host.*status.*up/i
        }.each do |line|
        tmp_a, ipaddress, hostname, *tmp_b = line.split

        hostname.gsub!(/[()]/, '')

        hostname  = nil if hostname.empty?
        ipaddress = IPAddr.new(ipaddress)
        device    = Device.new(hostname:  hostname,
                               ipaddress: ipaddress,
                               location:  location)

        devices.push(device)
      end

      location.devices = devices
    end

    def detect_devices_properties!
      ## TODO Run detection in threads
      self.locations.each do |location|
        location.devices.each do |device|
          Detector.detect_device_properties(device)
        end
      end
    end

    def self.detect_device_properties(device)
      snmp   = nil
      status = ''

      ['2c', '1'].each do |version|
        if status.empty?
          status = Helper::SNMP.status(device.ipaddress.to_s, version: version)
          snmp   = version unless status.empty?
        end
      end

      status << Helper::SNMP.bulkget(device.ipaddress.to_s,
                                     version: snmp,
                                     oids:    SNMP_STATUS_OIDS) if snmp
      status << Helper::NMAP.scan(device.ipaddress.to_s, '-O')

      device.networking      = 'lan'
      device.criticality     = 'prod'
      device.agent           = 'ping'    unless snmp
      device.agent           = 'snmp'    if snmp == '2c'
      device.agent           = 'snmp-v1' if snmp == '1'
      device.type            = Helper.map(TYPE_MAP, status).first
      device.model           = Helper.map(MODEL_MAP, status).first
      device.operatingsystem = Helper.map(OPERATING_SYSTEM_MAP, status).first
      device.services        = Helper.map(SERVICE_MAP, status)

      device
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
  detector.detect_devices_properties!

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
