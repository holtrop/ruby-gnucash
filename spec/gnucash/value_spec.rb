module Gnucash
  describe Value do
    it "raises an error when an unexpected string is given" do
      expect { Value.new("1234") }.to raise_error /Unexpected value string/
    end

    it "raises an error when an unexpected type is given" do
      expect { Value.new(Object.new) }.to raise_error /Unexpected value type/
    end

    it "allows construction from a string" do
      Value.new("5678/100").val.should == 5678
    end

    it "converts the value to the expected string representation" do
      Value.new("5678/100").to_s.should == "56.78"
      Value.new("1000231455/100").to_s.should == "10002314.55"
    end

    it "allows adding two value objects" do
      a = Value.new("1234/100")
      b = Value.new("2345/100")
      c = a + b
      c.to_s.should == "35.79"
    end

    it "allows subtracting two value objects" do
      a = Value.new("-12300/100")
      b = Value.new("99/100")
      c = a - b
      c.to_s.should == "-123.99"
    end

    it "formats the number with two decimal places" do
      Value.new("1400/100").to_s.should == "14.00"
    end
  end
end
