#!/usr/bin/env ruby
# vim:fileencoding=UTF-8 shiftwidth=2:

require 'ipaddr'
require 'open3'
require 'ostruct'
require 'pp'

# optional ruby gems
begin
  require 'progressbar'
  require 'thread/pool'
rescue LoadError
end


module CheckMK
  class Config < OpenStruct
    @@singleton = self.new

    def self.load
      @@singleton = self.new
    end

    def self.jobs
      @@singleton.jobs
    end

    def self.models
      @@singleton.models
    end

    def self.names
      @@singleton.names
    end

    def self.operatingsystems
      @@singleton.operatingsystems
    end

    def self.services
      @@singleton.services
    end

    def self.snmp_oids
      @@singleton.snmp_oids
    end

    def self.types
      @@singleton.types
    end

    def initialize
      super

      config = OpenStruct.new
      dir    = File.dirname($0)
      name   = File.basename($0, '.rb')

      files = [
        [ENV['%ProgramFiles(x86)%'], name, 'config.rb'],
        [ENV['%ProgramFiles%'],      name, 'config.rb'],
        [ENV['%ProgramData%'],       name, 'config.rb'],
        [ENV['%AppData%'],           name, 'config.rb'],
        ['', 'usr',          'share', name, 'config.rb'],
        ['', 'usr', 'local', 'share', name, 'config.rb'],
        ['', 'etc', name, 'config.rb'],
        ['', 'etc', name + '.cfg'],
        ['~', '.config', name, 'config.rb'],
        ['~', '.config', name + '.cfg'],
        ['~', '.' + name, 'config.rb'],
        ['~', '.' + name + '.cfg'],
        [dir, 'config.rb'],
        [dir, name + '.cfg'],
      ].select { |a| a.all? { |e| e } } .map { |a| File.join(a) }

      Dir.glob(files).each { |file| eval(File.read(file)) }
      config.each_pair { |k,v| self[k] = v }

      self
    end
  end

  module Helper
    module NMAP
      def self.ping(target, options = [])
        self.scan(target, ['-sP'] + options)
      end

      def self.scan(target, options = [])
        cmd = (['nmap'] + options + [target.to_s]).flatten
        status, stdout, stderr = Helper.exec(cmd)

        if status != 0
          cmd.reject! { |a| a =~ /-O/ }
          status, stdout, stderr = Helper.exec(cmd)
        end

        stdout.strip.lines.reject { |l| l =~ /Starting nmap.*http:\/\//i }.join('\n')
      end
    end


    module SNMP
      def self.status(agent, version: '2c', community: 'public')
        cmd = ["snmpstatus", "-r0", "-v#{version}", "-c#{community}", "-mALL", agent.to_s]
        status, stdout, stderr = Helper.exec(cmd)
        stdout
      end

      def self.bulkget(agent, version: '2c', community: 'public', oids: [])
        cmd = (["snmpbulkget", "-r0", "-v#{version}", "-c#{community}", "-mALL", agent.to_s] + oids).flatten
        status, stdout, stderr = Helper.exec(cmd)
        stdout
      end
    end

    def self.exec(cmd)
      stdout = ''
      stderr = ''
      status = 0

      begin
        stdout, strerr, status = Open3.capture3(*cmd)
      rescue Errno::ENOENT => e
        # TODO Test for nmap and snmpstatus at script start
      end

      [status, stdout, stderr]
    end

    def self.map(map, text)
      results = []

      map.each_pair do |value, regex|
        if text =~ regex
          results << value
        end
      end

      results
    end
  end


  class Device
    include Comparable
    attr_accessor :name, :hostname, :ipaddress, :location, :tags

    def initialize(hostname: nil, ipaddress: nil, location: nil)
      self.hostname  = hostname
      self.ipaddress = ipaddress
      self.location  = location
      self.tags      = OpenStruct.new

      if self.hostname.to_s.empty?
        self.name = Device.name_from_ipaddress(self.location, self.ipaddress)
      else
        self.name = self.hostname.sub(/\..*/i, '').upcase
      end
    end

    def <=>(other)
      self.to_s <=> other.to_s
    end

    def to_s
      self.name.to_s
    end

    def self.name_from_ipaddress(location, ipaddress)
      ipaddress_c = ipaddress.to_s.split('.')[2].to_i
      ipaddress_d = ipaddress.to_s.split('.')[3].to_i
      name        = ""

      Config.name_map.each_pair do |name_pattern, args|
        ipaddress_match = ipaddress.to_s =~ args[:ipaddress]
        location_match  = location.to_s  =~ (args[:location] || /./)

        if ipaddress_match && location_match
          name = name_pattern % { location:    location,
                                  ipaddress:   ipaddress.to_s,
                                  ipaddress_c: ipaddress_c + (args[:ipaddress_c] || 0),
                                  ipaddress_d: ipaddress_d + (args[:ipaddress_d] || 0), }
          break # Use only the first match from Config.name_map
        end
      end

      if name.to_s.empty?
        name = ipaddress.to_s
      end

      name.upcase
    end
  end


  class Location
    include Comparable

    attr_accessor :name, :ranges, :devices

    def initialize(name, ranges: [])
      self.name    = name
      self.devices = []
      self.ranges  = ranges
    end

    def <=>(other)
      self.name <=> other.name
    end

    def to_s
      self.name
    end
  end


  class Detector
    attr_accessor :locations

    def detect_devices(jobs = 8)
      Detector.progressbar_thread_pool(title: "Locations", elements: self.locations, jobs: jobs) do |location|
        Detector.detect_devices(location)
      end

      self
    end

    def self.detect_devices(location)
      devices = []

      Helper::NMAP.ping(location.ranges.join(' '), ['-oG', '-'])
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
          status = Helper::SNMP.status(device.ipaddress.to_s, version: version)
          snmp   = version unless status.empty?
        end
      end

      status << Helper::SNMP.bulkget(device.ipaddress.to_s,
                                     version: snmp,
                                     oids:    Config.snmp_status_oids) if snmp
      status << Helper::NMAP.scan(device.ipaddress.to_s, ['-O', '-sV'])

      device.tags.networking  = 'lan'
      device.tags.criticality = 'prod'
      device.tags.agent       = 'ping'    unless snmp
      device.tags.agent       = 'snmp'    if snmp == '2c'
      device.tags.agent       = 'snmp-v1' if snmp == '1'
      Helper.map(Config.model_map,   status).take(1).each { |m|  device.tags.model = m }
      Helper.map(Config.os_map,      status).take(1).each { |os| device.tags.operatingsystem = os }
      Helper.map(Config.type_map,    status).take(1).each { |t|  device.tags.type = t }
      Helper.map(Config.service_map, status)        .each { |s|  device.tags[s] = s }

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

    def self.progressbar_thread_pool(title: "", elements: [], jobs: 1, &block)
      pool        = Thread.pool(jobs) if (jobs > 1) && Thread.method_defined?(:pool)
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


if __FILE__ == $0
  CheckMK::Config.load

  detector = CheckMK::Detector.new

  detector.parse_locations(ARGF.read)
  detector.detect_devices(CheckMK::Config.jobs)
  detector.detect_devices_properties(CheckMK::Config.jobs)

  detector.locations.each do |location|
    puts "#{location.name} #{location.ranges.join(" ")}: #{location.devices.size} devices"

    location.devices.each do |device|
      puts "  #{device.name}"
      puts "    hostname:  #{device.hostname}"
      puts "    ipaddress: #{device.ipaddress}"
      puts "    location:  #{device.location.name}"
      puts "    tags:      " + device.tags.to_h.to_a.map { |a| a[0].to_s == a[1].to_s ? a[0].to_s : "#{a[0]}:#{a[1]}" }.sort.join(' ')
    end
  end
end
