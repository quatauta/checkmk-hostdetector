# -*- coding: utf-8; -*-
# frozen_string_literal: true
# vim:set fileencoding=utf-8:

require 'contracts'
require 'open3'

require 'checkmk/hostdetector/helper/nmap'
require 'checkmk/hostdetector/helper/snmp'

module CheckMK
  module HostDetector
    module Helper
      include Contracts


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
