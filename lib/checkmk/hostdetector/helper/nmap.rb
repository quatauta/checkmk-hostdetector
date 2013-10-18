# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'checkmk/hostdetector/helper'

module CheckMK
  module HostDetector
    module Helper
      module Nmap
        def self.ping(target, options = [])
          scan(target, ['-sP'] + options)
        end

        def self.scan(target, options = [])
          cmd = (['nmap'] + options + [target.to_s]).flatten
          status, stdout, stderr = Helper.exec(cmd)

          if status != 0
            cmd.reject! { |a| a =~ /-O/ }
            status, stdout, stderr = Helper.exec(cmd)
          end

          stdout.strip.lines.reject { |line|
            line =~ /(Starting nmap)|[0-9]\/(tcp|udp) +(closed|open\|filtered)/i
          }.join('\n')
        end
      end
    end
  end
end
