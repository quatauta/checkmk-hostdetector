# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'checkmk/devicedetector/config'

module CheckMK
  module DeviceDetector
    class Device
      include Comparable

      attr_accessor :name, :hostname, :ipaddress, :site, :tags

      def initialize(hostname: nil, ipaddress: nil, site: nil)
        self.hostname  = hostname
        self.ipaddress = ipaddress
        self.site      = site
        self.tags      = OpenStruct.new

        if self.hostname.to_s.empty?
          self.name = Device.name_from_ipaddress(self.site, self.ipaddress)
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

      def self.name_from_ipaddress(site, ipaddress)
        name = ""
        ip_c = ipaddress.to_s.split('.')[2].to_i
        ip_d = ipaddress.to_s.split('.')[3].to_i

        Config.names.each do |rule|
          ipaddress_regexp = (rule[:ip]   || '.').gsub('*', '[0-9]{1,3}').gsub('.', '\.')
          site_regexp      =  rule[:site] || '.'

          ipaddress_regexp = Regexp.new(ipaddress_regexp, Regexp::IGNORECASE)
          site_regexp      = Regexp.new(site_regexp,      Regexp::IGNORECASE)

          ipaddress_match = ipaddress.to_s =~ ipaddress_regexp
          site_match      = site.to_s      =~ site_regexp

          if ipaddress_match && site_match
            name = rule[:name] % {
              site: site,
              ip:   ipaddress.to_s,
              ip_c: ip_c + (rule[:ip_c] || 0),
              ip_d: ip_d + (rule[:ip_d] || 0), }
            break # Use only the first match from Config.names
          end
        end

        if name.to_s.empty?
          name = ipaddress.to_s
        end

        name.upcase
      end
    end
  end
end
