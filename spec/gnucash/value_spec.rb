module Gnucash
  describe Value do
    describe ".zero" do
      it "creates a Value object with value 0" do
        expect(Value.zero.val).to eq 0
      end
    end

    it "raises an error when an unexpected string is given" do
      expect { Value.new("1234") }.to raise_error /Unexpected value string/
    end

    it "raises an error when an unexpected type is given" do
      expect { Value.new(Object.new) }.to raise_error /Unexpected value type/
    end

    it "allows construction from a string" do
      expect(Value.new("5678/100").val).to eq 5678
    end

    it "converts the value to the expected string representation" do
      expect(Value.new("5678/100").to_s).to eq "56.78"
      expect(Value.new("1000231455/100").to_s).to eq "10002314.55"
    end

    it "converts the value to the expected float representation" do
      expect(Value.new("5678/100").to_f).to be_within(0.00000001).of(56.78)
      expect(Value.new("1000231455/100").to_f).to be_within(0.00000001).of(10002314.55)
    end

    it "converts the value to the expected rational representation" do
      expect(Value.new("5678/55").to_r).to eq Rational(5678, 55)
      expect(Value.new("1000231455/49").to_r).to eq Rational(1000231455, 49)
    end

    it "allows adding two value objects" do
      a = Value.new("1234/100")
      b = Value.new("2345/100")
      c = a + b
      expect(c.to_s).to eq "35.79"
    end

    it "allows adding a Value object to a Numeric" do
      a = Value.new("1234/100")
      b = 15
      c = a + b
      expect(c.round(2)).to eq 27.34
    end

    it "allows subtracting two value objects" do
      a = Value.new("-12300/100")
      b = Value.new("99/100")
      c = a - b
      expect(c.to_s).to eq "-123.99"
    end

    it "allows subtracting a Numeric from a Value object" do
      a = Value.new("890/100")
      b = 7.8
      c = a - b
      expect(c.round(2)).to eq 1.1
    end

    it "allows negating a Value object" do
      a = Value.new("123/100")
      b = -a
      expect(b.to_s).to eq "-1.23"
    end

    it "allows multiplying a Value by a Numeric" do
      a = Value.new("100/100")
      b = 12
      c = a * b
      expect(c.round(2)).to eq 12.00
    end

    it "allows multiplying a Value by a Value" do
      a = Value.new("100/100")
      b = Value.new(1200)
      c = a * b
      expect(c.round(2)).to eq 12.00
    end

    it "allows dividing a Value by a Numeric" do
      a = Value.new("150000/100")
      b = 150
      c = a / b
      expect(c.round(2)).to eq 10.0
    end

    it "allows dividing a Value by a Value" do
      a = Value.new("150000/100")
      b = Value.new(15000)
      c = a / b
      expect(c.round(2)).to eq 10.0
    end

    it "formats the number with two decimal places" do
      expect(Value.new("1400/100").to_s).to eq "14.00"
    end

    it "supports comparisons between two Value objects" do
      expect(Value.new("1234/100")).to eq Value.new(1234)
      expect((Value.new("89/100") < Value.new("100/100"))).to be_truthy
      expect((Value.new("1234/100") > Value.new("222/100"))).to be_truthy
    end

    it "converts between values with different divisors" do
      expect(Value.new("1234/10000") < Value.new("100/100")).to be_truthy
      expect(Value.new(7, 100) + Value.new(17, 1000)).to eq Value.new(87, 1000)
      expect(Value.new(80, 100) - Value.new(5, 50)).to eq Value.new(70, 100)
    end

    it "avoid inspection of heavier attributes" do
      expect(Value.new("1234/10000").inspect).to eq "#<Gnucash::Value val: 1234, div: 10000>"
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
