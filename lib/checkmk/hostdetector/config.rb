# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'ostruct'

module CheckMK
  module HostDetector
    class Config < OpenStruct
      @@singleton = new

      def self.load
        @@singleton = new
      end

      def self.jobs
        @@singleton.jobs
      end

      def self.models
        @@singleton.models
      end

      def self.names
        @@singleton.names
      end

      def self.operatingsystems
        @@singleton.operatingsystems
      end

      def self.services
        @@singleton.services
      end

      def self.snmp_oids
        @@singleton.snmp_oids
      end

      def self.types
        @@singleton.types
      end

      def initialize
        super

        config = OpenStruct.new
        dir    = File.dirname($PROGRAM_NAME)
        name   = File.basename($PROGRAM_NAME, '.rb')

        files = [
          [ENV['%ProgramFiles(x86)%'],  name, 'rules.rb'],
          [ENV['%ProgramFiles%'],       name, 'rules.rb'],
          [ENV['%ProgramData%'],        name, 'rules.rb'],
          [ENV['%AppData%'],            name, 'rules.rb'],
          ['', 'usr',          'share', name, 'rules.rb'],
          ['', 'usr', 'local', 'share', name, 'rules.rb'],
          ['', 'etc', name, 'rules.rb'],
          ['~', '.config', name, 'rules.rb'],
          ['~', '.' + name, 'rules.rb'],
          [dir, '..', 'config', 'rules.rb'],
        ].select { |a| a.all? { |e| e } } .map { |a| File.join(a) }

        Dir.glob(files).each { |file| eval(File.read(file)) }
        config.each_pair { |k,v| self[k] = v }

        self
      end
    end
  end
end