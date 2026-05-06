module Gnucash
  describe Security do
    before(:all) do
      @book = Gnucash.open("spec/books/pricedb-fixture.gnucash")
      @security = @book.find_security("TEST", "STK")
    end

    it "loads price rows from the fixture" do
      expect(@book.price_rows.size).to eq(4)
    end

    it "lists securities from the price database" do
      expect(@book.securities.size).to eq(2)
      ids = @book.securities.map(&:id).sort
      expect(ids).to eq(%w[ESFUND STK])
    end

    it "returns nil when the commodity is not priced" do
      expect(@book.find_security("NONE", "X")).to be_nil
    end

    describe "ISIN" do
      it "exposes isin from cmdty:xcode" do
        expect(@security.isin).to eq("US0378331005")
      end

      it "exposes isin from commodity slots" do
        s = @book.find_security("TEST", "ESFUND")
        expect(s.isin).to eq("ES0105046009")
      end

      it "finds security by ISIN ignoring case and spaces" do
        found = @book.find_security_by_isin("us 03783-31005")
        expect(found.id).to eq("STK")
        expect(@book.find_security_by_isin("ES0105046009").id).to eq("ESFUND")
      end

      it "returns nil when ISIN is unknown or commodity not priced" do
        expect(@book.find_security_by_isin("DE0000000000")).to be_nil
      end
    end

    it "supports light inspect on security and quote" do
      expect(@security.inspect).to include("TEST", "STK", "US0378331005")
      q = @security.value_on(Date.new(2020, 6, 1))
      expect(q.inspect).to include("currency_id", "USD")
    end

    describe "#value_on" do
      it "returns nil when the date is before the first quote" do
        expect(@security.value_on(Date.new(2019, 12, 31))).to be_nil
      end

      it "returns the most recent quote on or before the date" do
        q = @security.value_on(Date.new(2020, 3, 15))
        expect(q.value).to eq(Value.new("10000/100"))
        expect(q.date).to eq(Date.new(2020, 1, 1))

        q2 = @security.value_on(Date.new(2020, 6, 1))
        expect(q2.value).to eq(Value.new("15000/100"))
        expect(q2.date).to eq(Date.new(2020, 6, 1))

        q3 = @security.value_on("2020-12-31")
        expect(q3.date).to eq(Date.new(2020, 6, 1))
        expect(q3.value).to eq(Value.new("15000/100"))
      end

      it "accepts an explicit quote currency" do
        q = @security.value_on(
          Date.new(2020, 12, 31),
          currency_space: "CURRENCY",
          currency_id: "USD"
        )
        expect(q.value.to_f).to eq(150.0)
        expect(q.date).to eq(Date.new(2020, 6, 1))
      end

      it "raises when only one currency keyword is given" do
        expect {
          @security.value_on(Date.new(2020, 1, 1), currency_space: "CURRENCY")
        }.to raise_error(ArgumentError)
      end
    end
  end
end
