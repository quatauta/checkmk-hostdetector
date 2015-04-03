# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'contracts'

module CheckMK
  module HostDetector
    class Site
      include Comparable
      include Contracts

      attr_accessor :name, :ranges, :hosts

      Contract String, Maybe[ArrayOf[Host]], Maybe[ArrayOf[String]] => Site
      def initialize(name, hosts: [], ranges: [])
        self.name   = name
        self.hosts  = []
        self.ranges = ranges
      end

      Contract Site => Num
      def <=>(other)
        name <=> other.name
      end

      Contract None => String
      def to_s
        name
      end
    end
  end
end
