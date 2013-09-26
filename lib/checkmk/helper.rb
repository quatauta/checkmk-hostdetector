# -*- coding: utf-8-unix; mode: ruby; -*-
# vim:set fileencoding=UTF-8 syntax=ruby:

require 'open3'

module CheckMK
  module Helper
    autoload :Nmap, 'checkmk/helper/nmap'
    autoload :Snmp, 'checkmk/helper/snmp'

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
