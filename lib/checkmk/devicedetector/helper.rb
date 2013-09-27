# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'open3'

module CheckMK
  module DeviceDetector
    module Helper
      autoload :Nmap, 'checkmk/devicedetector/helper/nmap'
      autoload :Snmp, 'checkmk/devicedetector/helper/snmp'

      def self.exec(cmd)
        stdout, stderr, status = Open3.capture3(*cmd)

        [status, stdout, stderr]
      end

      def self.map(map, text)
        results = []

        map.each do |rule|
          results << rule[:value] if text =~ rule[:regex]
        end

        results
      end
    end
  end
end
