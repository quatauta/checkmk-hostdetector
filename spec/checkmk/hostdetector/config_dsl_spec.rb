# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

require 'checkmk/hostdetector/config_dsl'

module CheckMK::HostDetector
  describe ConfigDSL do
    describe "#initialize" do
      it "is empty after creation" do
        expect(subject.instance_variables).to be_empty
        expect(subject.methods).to be_nil
      end

      it "returns nil on undefined options" do
        expect(subject.option_a).to be_nil
        expect(subject.option_b).to be_nil
        expect(subject.option_c).to be_nil
      end
    end

    describe "#load" do
      it "loads one option into array" do
        subject.load('option_a "123"')
        expect(subject.option_a).to match_array(["123"])
      end

      it "loads multiple options into array" do
        subject.load('option_a "123"')
        subject.load('option_a "234"')
        subject.load('option_a "345"')
        expect(subject.option_a).to match_array(["123", "234", "345"])
      end

      it "loads multiple options of different types into array" do
        subject.load('option_a "123"')
        subject.load('option_a 234')
        subject.load('option_a /345/')
        expect(subject.option_a).to match_array(["123", 234, /345/])
      end
    end

    describe "#load_from_file" do
      it "reads file content " do
        filename = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'config_dsl_example.rb')
        subject.load_file(filename)
        expect(subject.option_a).to match_array(["Is a string", "or", "some", "more strings"])
        expect(subject.option_b).to match_array([123, 234, /Peter/])
      end
    end
  end
end
