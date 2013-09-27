# -*- coding: UTF-8; -*-
# vim:set fileencoding=UTF-8:

module CheckMK
  module DeviceDetector
    # Read rails-like configuration from YAML-file with environments (like production,
    # development, test, ...). Take a look at rails database configuration files for
    # examples.
    #
    # All configuration values from YAML-file are accessible through methods named the
    # same way as the configuration values.
    class Configuration
      # Raw data loaded from YAML-file
      attr_reader :data

      # Environment set on object initialization
      attr_reader :env

      # Create a new Configuration
      #
      # +args+ hash may contain +env+, +path+ and +filename+
      # +env+ is the environment whoose configuration values are made accessible
      # +path+ is the directory to look for the configuration file
      # +filename+ is the name of the configuration file to load
      #
      # See +defaults+ for default values
      def initialize(args = {})
        args  = defaults.merge(args)
        @env  = args[:env]
        @data = YAML::load_file(File.join(args[:path],
                                          args[:filename]))

        define_methods_for_environment
      end

      # Default values used on object initialization
      def defaults
        { env:      'production',
          path:     File.join('config'),
          filename: 'config.yaml' }
      end

      # Define methods to access the configuration values for the environment set on
      # object initialization
      def define_methods_for_environment
        data[env].each do |name, value|
          instance_eval 'def %s \n "%s" \n end' % [ name, value ]
        end
      end
    end
  end
end
