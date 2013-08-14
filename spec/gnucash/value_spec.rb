module Gnucash
  describe Value do
    describe '.zero' do
      it 'creates a Value object with value 0' do
        Value.zero.val.should == 0
      end
    end

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

    it "allows adding a Value object to a Numeric" do
      a = Value.new("1234/100")
      b = 15
      c = a + b
      c.should == 27.34
    end

    it "allows subtracting two value objects" do
      a = Value.new("-12300/100")
      b = Value.new("99/100")
      c = a - b
      c.to_s.should == "-123.99"
    end

    it "allows subtracting a Numeric from a Value object" do
      a = Value.new("890/100")
      b = 7.8
      c = a - b
      c.should == 1.1
    end

    it "allows multiplying a Value by a Numeric" do
      a = Value.new("100/100")
      b = 12
      c = a * b
      c.should == 12.00
    end

    it "allows dividing a Value by a Numeric" do
      a = Value.new("150000/100")
      b = 150
      c = a / b
      c.should == 10.0
    end

    it "formats the number with two decimal places" do
      Value.new("1400/100").to_s.should == "14.00"
    end

    it "supports comparisons between two Value objects" do
      Value.new("1234/100").should == Value.new(1234)
      (Value.new("89/100") < Value.new("100/100")).should be_true
      (Value.new("1234/100") > Value.new("222/100")).should be_true
    end

    context "errors" do
      it "raises an error when attempting to add an unknown object type" do
        expect { Value.new(33) + nil }.to raise_error /Unexpected argument/i
      end

      it "raises an error when attempting to subtract an unknown object type" do
        expect { Value.new(33) - nil }.to raise_error /Unexpected argument/i
      end

      it "raises an error when attempting to multiply by an unknown object type" do
        expect { Value.new(33) * nil }.to raise_error /Unexpected argument/i
      end

      it "raises an error when attempting to divide by an unknown object type" do
        expect { Value.new(33) / nil }.to raise_error /Unexpected argument/i
      end
    end
  end
end
