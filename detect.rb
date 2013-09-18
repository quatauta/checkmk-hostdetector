#!/usr/bin/env ruby

require 'awesome_print'
require 'ipaddr'
require 'pp'


module CheckMK
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
      if !self.hostname.empty?
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
      (self.hostname || self.ipaddress).to_s
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

      `nmap -sP -oG - #{ranges.join(' ')}`.lines.select { |l| l =~ /host.*status.*up/i }.each do |line|
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
      ## TODO
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
