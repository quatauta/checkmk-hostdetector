# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'checkmk/devicedetector/config'

module CheckMK
  module DeviceDetector
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
        name = ""
        ip_c = ipaddress.to_s.split('.')[2].to_i
        ip_d = ipaddress.to_s.split('.')[3].to_i

        Config.names.each do |rule|
          ipaddress_regexp = (rule[:ip]       || '.').gsub('*', '[0-9]{1,3}').gsub('.', '\.')
          location_regexp  =  rule[:location] || '.'

          ipaddress_regexp = Regexp.new(ipaddress_regexp, Regexp::IGNORECASE)
          location_regexp  = Regexp.new(location_regexp,  Regexp::IGNORECASE)

          ipaddress_match = ipaddress.to_s =~ ipaddress_regexp
          location_match  = location.to_s  =~ location_regexp

          if ipaddress_match && location_match
            name = rule[:name] % { location:    location,
              ipaddress:   ipaddress.to_s,
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
