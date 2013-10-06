# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

module CheckMK::HostDetector
  class Site
    include Comparable

    attr_accessor :name, :ranges, :hosts

    def initialize(name, hosts: [], ranges: [])
      self.name   = name
      self.hosts  = []
      self.ranges = ranges
    end

    def <=>(other)
      name <=> other.name
    end

    def to_s
      name
    end
  end
end
