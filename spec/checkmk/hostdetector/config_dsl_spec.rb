require 'checkmk/hostdetector/config_dsl'

module CheckMK::HostDetector
  describe ConfigDSL do
    describe "#load" do
      it "loads configuration from string" do
        config = ConfigDSL.new
        config.test_config.should == nil
        config.load 'test_config "123"'
        config.test_config.should == ["123"]
      end
    end
  end
end
