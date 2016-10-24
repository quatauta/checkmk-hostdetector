# -*- coding: utf-8; -*-
# frozen_string_literal: true
# vim:set fileencoding=utf-8:

require 'checkmk/hostdetector/helper'
require 'contracts'

module CheckMK
  module HostDetector
    module Helper
      module Nmap
        include Contracts

        Contract String, Maybe[ArrayOf[String]] => String
        def self.ping(target, options = [])
          scan(target, ['-sP'] + options)
        end

        Contract String, Maybe[ArrayOf[String]] => String
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
