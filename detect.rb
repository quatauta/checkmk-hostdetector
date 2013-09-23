#!/usr/bin/env ruby
# vim:fileencoding=UTF-8 shiftwidth=2:

# This script needs rubygems:
#  - open4  >= 1.3.0
#  - thread >= 0.1.1

require 'ipaddr'
require 'open4'
require 'ostruct'
require 'pp'
require 'thread/pool'


module CheckMK
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
      stdin  = ''
      stdout = ''
      stderr = ''
      status = Open4::spawn(*cmd, 'stdin' => stdin, 'stdout' => stdout, 'stderr' => stderr,
                            'raise' => false, 'quiet' => true)

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

    NAME_MAP = {
      # Router/Brickbox
      "%<location>sR01" => { ipaddress: /\b10\.9\.[0-9]{1,3}\.1\b/i },
      "%<location>sR11" => { ipaddress: /\b10\.190\.[0-9]{1,3}\.1\b/i },
      "%<location>sR21" => { ipaddress: /\b10\.190\.[0-9]{1,3}\.16\b/i },

      # Switches in TR01/TR10 (23-bit subnetmask)
      "%<location>sS%<ipaddress_c>03d%<ipaddress_d>02d" => { ipaddress: /\b10\.9\.(112|113|114|115)\.3[1-9]\b/i,
                                                             ipaddress_d: -30 },
      # Switches in TR11, frist overwrite rule for all other switches
      "" => { ipaddress: /\b10\.9\.[0-9]{1,3}\.3[1-9]\b/i, location: /tr11/i },
      "%<location>sS0K1" => { ipaddress: /10.9.145.6/i,  location: /tr11/i },
      "%<location>sS101" => { ipaddress: /10.9.145.10/i, location: /tr11/i },
      "%<location>sS102" => { ipaddress: /10.9.145.11/i, location: /tr11/i },
      "%<location>sS111" => { ipaddress: /10.9.145.12/i, location: /tr11/i },
      "%<location>sS112" => { ipaddress: /10.9.145.13/i, location: /tr11/i },
      "%<location>sS121" => { ipaddress: /10.9.145.14/i, location: /tr11/i },
      "%<location>sS122" => { ipaddress: /10.9.145.15/i, location: /tr11/i },
      "%<location>sS131" => { ipaddress: /10.9.145.16/i, location: /tr11/i },
      "%<location>sS132" => { ipaddress: /10.9.145.17/i, location: /tr11/i },
      "%<location>sS141" => { ipaddress: /10.9.145.18/i, location: /tr11/i },
      "%<location>sS142" => { ipaddress: /10.9.145.19/i, location: /tr11/i },
      "%<location>sS151" => { ipaddress: /10.9.145.20/i, location: /tr11/i },
      "%<location>sS152" => { ipaddress: /10.9.145.21/i, location: /tr11/i },
      "%<location>sS161" => { ipaddress: /10.9.145.22/i, location: /tr11/i },
      "%<location>sS162" => { ipaddress: /10.9.145.23/i, location: /tr11/i },
      "%<location>sS311" => { ipaddress: /10.9.145.24/i, location: /tr11/i },
      "%<location>sS312" => { ipaddress: /10.9.145.25/i, location: /tr11/i },
      # Standard switches
      "%<location>sS%<ipaddress_d>02d" => { ipaddress: /\b10\.9\.[0-9]{1,3}\.3[1-9]\b/i },

      # TK-Anlagen
      "%<location>sTK%<ipaddress_d>02d" => { ipaddress: /\b10\.9\.[0-9]{1,3}\.(23[0-9]|240)\b/i, ipaddress_d: -229 },
    }

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

      NAME_MAP.each_pair do |name_pattern, args|
        ipaddress_match = ipaddress.to_s =~ args[:ipaddress]
        location_match  = location.to_s  =~ (args[:location] || /./)

        if ipaddress_match && location_match
          name = name_pattern % { location:    location,
                                  ipaddress:   ipaddress.to_s,
                                  ipaddress_c: ipaddress_c + (args[:ipaddress_c] || 0),
                                  ipaddress_d: ipaddress_d + (args[:ipaddress_d] || 0), }
          break # Use only the first match from NAME_MAP
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
      self.name   = name
      self.ranges = ranges
    end

    def <=>(other)
      self.name <=> other.name
    end

    def to_s
      self.name
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
      'brickbox'   => /\b10\.9\.[0-9]{1,3}\.1\b/i,
      'brickbox'   => /\b[a-z]{2}[0-9]{2}r[0-9]{2}\b/i,
      'drac'       => /\b[a-z]{2}[0-9]{2}rb[cmv][0-9]{2}\b/i,
      'printer'    => /brother.*nc/i, # u.a. Brother MFC-6490CW
      'printer'    => /canon.*mx/i,
      'printer'    => /dlink.*print/i,
      'printer'    => /hp.*ethernet/i, # u.a. HP OfficeJet Pro 8600 N911a
      'printer'    => /jetdirect/i,
      'printer'    => /konica.*minolta/i,
      'printer'    => /kyocera/i,
      'printer'    => /lexmark/i,
      'richtfunk'  => /airlaser|city.*link/i,
      'server-tr'  => /\b[a-z]{2}[0-9]{2}sdm/i,
      'server-tr'  => /\b[a-z]{2}[0-9]{2}srv/i,
      'server-tr'  => /\b[a-z]{2}[0-9]{2}sto/i,
      'server-tr'  => /\b[a-z]{2}[0-9]{2}svh/i,
      'server-zpt' => /\b[a-z]{2}[0-9]{2}sdc/i,
      'switch'     => /switch|superstack/i,
      'tkanlage'   => /\b10\.9\.[0-9]{1,3}\.(23[0-9]|240)\b/i,
      'tkanlage'   => /\b[a-z]{2}[0-9]{2}tk[0-9]{2}\b/i,
    }

    OS_MAP = {
      'drac'       => /dell.*remote.*access/i,
      'drac'       => /linux.*rb[cm]/i,
      'equallogic' => /equallogic|eqlappliance/i,
      'linux'      => /linux.*srv/i,
      'linux'      => /linux/i,
      'vmware-esx' => /vmware.*esx/i,
      'windows'    => /windows/i,
    }

    MODEL_MAP = {
      'vmware-vm'             => /mac.*00:50:56.*vmware/i,
      '3com-3824'             => /3com.*switch.*3824/i,
      '3com-4400'             => /3com.*switch.*4400/i,
      '3com-4500'             => /3com.*switch.*4500/i,
      '3com-5500g'            => /3com.*switch.*5500g/i,
      'canon-mx-850'          => /canon.*mx.*850/i,
      'dell-2900'             => /poweredge.*2900/i,
      'dell-r520'             => /poweredge.*r520/i,
      'dell-r710'             => /poweredge.*r710/i,
      'dell-t300'             => /poweredge.*t300/i,
      'dell-t420'             => /poweredge.*t420/i,
      'fsc-h250'              => /primergy.*h.*250/i,
      'fsc-tx300'             => /primergy.*tx.*300/i,
      'hipath-4000'           => /sco.*(open|unix)/i,
      'hp-a5120'              => /hp.*a5120.*switch/i,
      'hp-clj-3550'           => /hp.*color.*laserjet.*3550/i,
      'hp-clj-3600'           => /hp.*color.*laserjet.*3600/i,
      'hp-clj-4650'           => /hp.*color.*laserjet.*4650/i,
      'hp-clj-cp3525'         => /hp.*color.*laserjet.*cp3525/i,
      'koncia-magicolor-5450' => /konica.*5450/i,
      'konica-bizhub-222'     => /konica.*222/i,
      'lexmark-c734'          => /lexmark.*c734/i,
      'lexmark-c746'          => /lexmark.*c746/i,
      'lexmark-e460'          => /lexmark.*e460/i,
      'lexmark-t640'          => /lexmark.*t640/i,
      'lexmark-x463'          => /lexmark.*x463/i,
      'lexmark-x464'          => /lexmark.*x464/i,
    }

    SERVICE_MAP = {
      'backupexecagent'  => /10000.*(ndmp|backup.*exec|snet-sensor)/i,
      'backupexecserver' => /[^t][^r][^1][^0]sdm00|tr10sdm12\b/i,
      'dhcp'             => /dhcp/i,
      'dns'              => /53.*(dns|domain)/i,
      'empirumdepot'     => /sdm00\b/i,
      'fileserver'       => /13[789].*netbios/i,
      'http'             => /80.*http\b/i,
      'https'            => /443.*(https|ssl.*http)/i,
      'iperf'            => /5001.*iperf/i,
      'iscsi'            => /(860|3260).*iscsi/i,
      'ldap'             => /389.*ldap\b/i,
      'ldaps'            => /636.*(ldaps|ssl.*ldap)/i,
      'mssql'            => /1433.*ms-sql-s/i,
      'mysql'            => /3306.*mysql/i,
      'mssql2005'        => /sql.*server.*2005/i,
      'mssql2008'        => /sql.*server.*2008/i,
      'netlogon'         => /sdm00\b/i,
      'officescanclient' => /12345.*(netbus|officescan)/i,
      'printserver'      => /sdm00\b/i,
      'profiles'         => /sdm00\b/i,
      'rdp'              => /3389.*ms-wbt-server/i,
      'rsync'            => /873.*rsync/i,
      'smtp'             => /25.*smtp\b/i,
      'smtps'            => /465.*(smtps|ssl.*smtp)/i,
      'ssh'              => /22.*ssh/i,
      'user-p'           => /sdm00\b/i,
      'wsus'             => /sdm00\b/i,
    }

    attr_accessor :locations

    def detect_devices!(jobs = 8)
      pool = Thread.pool(jobs)

      self.locations.each do |location|
        pool.process do
          Detector.detect_devices(location)
          $stderr.print("#{location.name} #{location.ranges.join(' ')}: #{location.devices.size} devices\n")
        end
      end

      pool.wait_done
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

    def detect_devices_properties!(jobs = 8)
      pool = Thread.pool(jobs)

      self.locations.each do |location|
        location.devices.each do |device|
          pool.process do
            Detector.detect_device_properties(device)
            $stderr.print("#{device.ipaddress} #{device.hostname} #{device.name} done\n")
          end
        end
      end

      pool.wait_done
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
                                     oids:    SNMP_STATUS_OIDS) if snmp
      status << Helper::NMAP.scan(device.ipaddress.to_s, ['-O', '-sV'])

      device.tags.networking  = 'lan'
      device.tags.criticality = 'prod'
      device.tags.agent       = 'ping'    unless snmp
      device.tags.agent       = 'snmp'    if snmp == '2c'
      device.tags.agent       = 'snmp-v1' if snmp == '1'
      Helper.map(TYPE_MAP,  status).take(1).each { |t|  device.tags.type  = t }
      Helper.map(MODEL_MAP, status).take(1).each { |m|  device.tags.model = m }
      Helper.map(OS_MAP,    status).take(1).each { |os| device.tags.operatingsystem = os }
      Helper.map(SERVICE_MAP, status).each { |s| device.tags[s] = s }

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
      puts "    hostname:  #{device.hostname}"
      puts "    ipaddress: #{device.ipaddress}"
      puts "    location:  #{device.location.name}"

      device.tags.each_pair do |tag, value|
        puts "    tag_#{tag}: #{value}"
      end
    end
  end
end
