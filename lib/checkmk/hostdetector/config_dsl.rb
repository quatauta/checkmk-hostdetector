# -*- coding: utf-8; -*-
# frozen_string_literal: true
# vim:set fileencoding=utf-8:

module CheckMK
  module HostDetector
    class ConfigDSL
      KEEP_METHODS = %w( __id__ __send__ class inspect instance_eval
                         instance_variables object_id send
                         == === eql to_s ).map(&:to_sym)

      instance_methods.each do |method|
        undef_method(method) unless KEEP_METHODS.include? method
      end

      def self.dsl_accessor(*symbols)
        symbols.each do |sym|
          class_eval %{
            def #{sym}(*val)
              if val.empty?
                @#{sym}
              else
                val = [val] if val.size > 1

                if @#{sym}
                  @#{sym}.push(*val)
                else
                  @#{sym} = val
                end
              end
            end
          }
        end
      end

      def method_missing(sym, *args)
        self.class.dsl_accessor sym
        send(sym, *args)
      end

      def respond_to_missing?(method_name, include_private = false)
        self.methods.inclde(method_name) || super
      end

      def load(text, filename = '(inline string)')
        instance_eval(text, filename)
      end

      def load_file(*filenames)
        filenames.flatten.each do |filename|
          load(File.read(filename), filename)
        end

        self
      end
    end
  end
end
