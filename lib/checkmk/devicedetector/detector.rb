# -*- coding: utf-8-unix; mode: ruby; -*-
# vim:set fileencoding=UTF-8 syntax=ruby:

require 'checkmk/devicedetector/config'
require 'checkmk/devicedetector/device'
require 'checkmk/devicedetector/helper'
require 'checkmk/devicedetector/location'
require 'checkmk/devicedetector/version'
require 'ipaddr'
require 'progressbar'
require 'thread/pool'


module CheckMK
  module DeviceDetector
    class Detector
      attr_accessor :locations

      def detect_devices(jobs = 8)
        Detector.progressbar_thread_pool(title:    "Locations",
                                         elements: self.locations,
                                         jobs:     jobs) do |location|
          Detector.detect_devices(location)
        end

        self
      end

      def self.detect_devices(location)
        devices = []

        Helper::Nmap.ping(location.ranges.join(' '), ['-oG', '-'])
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

      def detect_devices_properties(jobs = 8)
        devices = self.locations.inject([]) { |a, location| a.push(*location.devices) }

        Detector.progressbar_thread_pool(title: "Devices", elements: devices, jobs: jobs) do |device|
          Detector.detect_device_properties(device)
        end

        self
      end

      def self.detect_device_properties(device)
        snmp   = nil
        status = ''

        ['2c', '1'].each do |version|
          if status.empty?
            status = Helper::Snmp.status(device.ipaddress.to_s, version: version)
            snmp   = version unless status.empty?
          end
        end

        status << Helper::Snmp.bulkget(device.ipaddress.to_s,
                                       version: snmp,
                                       oids:    Config.snmp_status_oids) if snmp
        status << Helper::Nmap.scan(device.ipaddress.to_s, %w[-O -sV])
        status << Helper::Nmap.scan(device.ipaddress.to_s, %w[-sU -p53,67])

        device.tags.networking  = 'lan'
        device.tags.criticality = 'prod'
        device.tags.agent       = 'ping'    unless snmp
        device.tags.agent       = 'snmp'    if snmp == '2c'
        device.tags.agent       = 'snmp-v1' if snmp == '1'
        Helper.map(Config.models,           status).take(1).each { |m|  device.tags.model = m }
        Helper.map(Config.operatingsystems, status).take(1).each { |os| device.tags.operatingsystem = os }
        Helper.map(Config.types,            status).take(1).each { |t|  device.tags.type = t }
        Helper.map(Config.services,         status)        .each { |s|  device.tags[s] = s }

        device
      end

      def parse_locations(text = '')
        self.locations = Detector::parse_locations(text)
        self
      end

      def self.parse_locations(text = '')
        locations = []

        text.each_line do |line|
          name, *ranges = line.split

          locations.push(Location.new(name, ranges: ranges))
        end

        locations
      end

      def self.progressbar_thread_pool(title: "", elements: [], jobs: 8, &block)
        pool        = Thread::Pool.new(jobs) if (jobs > 1) && Thread.const_defined?(:Pool)
        tasks       = []
        progressbar = ProgressBar.new("#{elements.size} #{title}", elements.size) if Kernel.const_defined? :ProgressBar
        semaphore   = Mutex.new

        elements.each do |e|
          yield_inc = proc {
            yield(e)
            semaphore.synchronize { progressbar.inc } if progressbar
          }

          if pool
            tasks << pool.process { yield_inc.call }
          else
            yield_inc.call
          end
        end

        pool.wait_done if pool
        progressbar.finish if progressbar
        tasks.map { |t| t.exception }.compact.each { |e| raise e }
      end
    end
  end
end
