# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'contracts'
require 'open3'

module CheckMK
  module HostDetector
    module Helper
      include Contracts
      include Contracts::Modules

      autoload :Nmap, 'checkmk/hostdetector/helper/nmap'
      autoload :Snmp, 'checkmk/hostdetector/helper/snmp'

      Contract Args[String] => [Num, String, String]
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
