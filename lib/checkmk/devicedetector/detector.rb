# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'checkmk/devicedetector'
require 'ipaddr'

begin
  require 'progressbar'
  require 'thread/pool'
rescue LoadError
end


module CheckMK
  module DeviceDetector
    class Detector
      attr_accessor :sites

      def detect_devices(jobs = 8)
        Detector.progressbar_thread_pool(title:    "Sites",
                                         elements: self.sites,
                                         jobs:     jobs) do |site|
          Detector.detect_devices(site)
        end

        self
      end

      def self.detect_devices(site)
        devices = []

        Helper::Nmap.ping(site.ranges.join(' '), ['-oG', '-'])
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
                                 site:      site)

          devices.push(device)
        end

        site.devices = devices
      end

      def detect_devices_properties(jobs = 8)
        devices = self.sites.inject([]) { |a, site| a.push(*site.devices) }

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

      def parse_sites(text = '')
        self.sites = Detector::parse_sites(text)
        self
      end

      def self.parse_sites(text = '')
        sites = []

        text.each_line do |line|
          name, *ranges = line.split

          sites.push(Site.new(name, ranges: ranges))
        end

        sites
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
