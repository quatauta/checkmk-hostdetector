# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

module CheckMK
  module HostDetector
    class ConfigDSL
      KEEP_METHODS = %w[ __id__ __send__ class inspect instance_eval instance_variables object_id send ].map { |str| str.to_sym }

      instance_methods.each do |method|
        unless KEEP_METHODS.include? method
          undef_method(method)
        end
      end

      def self.dsl_accessor(*symbols)
        symbols.each { |sym|
          class_eval %{
            def #{sym}(*val)
              if val.empty?
                @#{sym}
              else
                if @#{sym}
                  @#{sym}.push(*val)
                else
                  @#{sym} = val
                end
              end
            end
          }
        }
      end

      def method_missing(sym, *args)
        self.class.dsl_accessor sym
        send(sym, *args)
      end

      def load(*filenames)
        filenames.flatten.each do |filename|
          instance_eval(File.read(filename), filename)
        end

        self
      end

      def self.load(*filenames)
        dsl = new

        dsl.load(filenames)
        dsl
      end
    end
  end
end
