# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'checkmk/hostdetector/helper'
require 'contracts'

module CheckMK
  module HostDetector
    module Helper
      module Snmp
        include Contracts
        include Contracts::Modules

        Contract String, Maybe[String], Maybe[String] => String
        def self.status(agent, version: '2c', community: 'public')
          cmd = ['snmpstatus', '-r0', "-v#{version}", "-c#{community}", '-mALL', agent.to_s]
          status, stdout, stderr = Helper.exec(cmd)
          stdout
        end

        Contract String, String, String, ArrayOf[String] => String
        def self.bulkget(agent, version: '2c', community: 'public', oids: [])
          cmd = (['snmpbulkget', '-r0', "-v#{version}", "-c#{community}", '-mALL', agent.to_s] + oids).flatten
          status, stdout, stderr = Helper.exec(cmd)
          stdout
        end
      end
    end
  end
end
