# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'open3'

module CheckMK
  module HostDetector
    module Helper
      autoload :Nmap, 'checkmk/hostdetector/helper/nmap'
      autoload :Snmp, 'checkmk/hostdetector/helper/snmp'

      def self.exec(cmd)
        stdout, stderr, status = Open3.capture3(*cmd)

        [status, stdout, stderr]
      end

      def self.map(map, text)
        results = []

        map.each do |rule|
          if text =~ rule.last
            results << [rule.first, rule[1]]    if 3 == rule.size
            results << [rule.first, rule.first] if 2 == rule.size
          end
        end

        results
      end
    end
  end
end
