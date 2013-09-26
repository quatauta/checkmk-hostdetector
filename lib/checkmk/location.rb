# -*- coding: utf-8-unix; mode: ruby; -*-
# vim:set fileencoding=UTF-8 syntax=ruby:

module CheckMK
  class Location
    include Comparable

    attr_accessor :name, :ranges, :devices

    def initialize(name, ranges: [])
      self.name    = name
      self.devices = []
      self.ranges  = ranges
    end

    def <=>(other)
      self.name <=> other.name
    end

    def to_s
      self.name
    end
  end
end
