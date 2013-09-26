# -*- coding: utf-8-unix; mode: ruby; -*-
# vim:set fileencoding=UTF-8 syntax=ruby:

module CheckMK
  module Helper
    module Snmp
      def self.status(agent, version: '2c', community: 'public')
        cmd = ["snmpstatus", "-r0", "-v#{version}", "-c#{community}", "-mALL", agent.to_s]
        status, stdout, stderr = Helper.exec(cmd)
        stdout
      end

      def self.bulkget(agent, version: '2c', community: 'public', oids: [])
        cmd = (["snmpbulkget", "-r0", "-v#{version}", "-c#{community}", "-mALL", agent.to_s] + oids).flatten
        status, stdout, stderr = Helper.exec(cmd)
        stdout
      end
    end
  end
end
