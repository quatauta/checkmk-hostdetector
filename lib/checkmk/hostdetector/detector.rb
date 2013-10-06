# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'checkmk/hostdetector'
require 'ipaddr'

begin
  require 'progressbar'
  require 'thread/pool'
rescue LoadError
end


module CheckMK
  module HostDetector
    class Detector
      attr_accessor :sites

      def detect_hosts(jobs = 8)
        Detector.progressbar_thread_pool(title:    'Sites',
                                         elements: sites,
                                         jobs:     jobs) do |site|
          Detector.detect_hosts(site)
        end

        self
      end

      def self.detect_hosts(site)
        hosts = []

        Helper::Nmap.ping(site.ranges.join(' '), ['-oG', '-'])
          .lines
          .select { |l| l =~ /host.*status.*up/i }
          .each do |line|
          tmp_a, ipaddress, hostname, *tmp_b = line.split

          hostname.gsub!(/[()]/, '')

          hostname  = nil if hostname.empty?
          ipaddress = IPAddr.new(ipaddress)
          host    = Host.new(hostname:  hostname,
                               ipaddress: ipaddress,
                               site:      site)

          hosts.push(host)
        end

        site.hosts = hosts
      end

      def detect_hosts_properties(jobs = 8)
        hosts = sites.reduce([]) { |a, site| a.push(*site.hosts) }

        Detector.progressbar_thread_pool(title: 'Hosts', elements: hosts, jobs: jobs) do |host|
          Detector.detect_host_properties(host)
        end

        self
      end

      def self.detect_host_properties(host)
        snmp   = nil
        status = ''

        ['2c', '1'].each do |version|
          if status.empty?
            status = Helper::Snmp.status(host.ipaddress.to_s, version: version)
            snmp   = version unless status.empty?
          end
        end

        status << Helper::Snmp.bulkget(host.ipaddress.to_s,
                                       version: snmp,
                                       oids:    Config.snmp_status_oids) if snmp
        status << Helper::Nmap.scan(host.ipaddress.to_s, %w[-O -sV])
        status << Helper::Nmap.scan(host.ipaddress.to_s, %w[-sU -p53,67])

        host.tags.networking  = 'lan'
        host.tags.criticality = 'prod'
        host.tags.agent       = 'ping'    unless snmp
        host.tags.agent       = 'snmp'    if snmp == '2c'
        host.tags.agent       = 'snmp-v1' if snmp == '1'
        Helper.map(Config.models,           status).take(1).each { |m|  host.tags.model = m }
        Helper.map(Config.operatingsystems, status).take(1).each { |os| host.tags.operatingsystem = os }
        Helper.map(Config.types,            status).take(1).each { |t|  host.tags.type = t }
        Helper.map(Config.services,         status)        .each { |s|  host.tags[s] = s }

        host
      end

      def parse_sites(text = '')
        self.sites = Detector.parse_sites(text)
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

      def self.progressbar_thread_pool(title: '', elements: [], jobs: 8, &block)
        pool        = Thread::Pool.new(jobs) if (jobs > 1) && Thread.const_defined?(:Pool)
        tasks       = []
        progressbar = ProgressBar.new("#{elements.size} #{title}", elements.size) if Kernel.const_defined? :ProgressBar
        semaphore   = Mutex.new

        elements.each do |e|
          yield_inc = proc do
            yield(e)
            semaphore.synchronize { progressbar.inc } if progressbar
          end

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
