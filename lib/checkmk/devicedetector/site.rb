# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

module CheckMK
  module DeviceDetector
    class Site
      include Comparable

      attr_accessor :name, :ranges, :devices

      def initialize(name, devices: [], ranges: [])
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
end
