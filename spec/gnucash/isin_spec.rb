module Gnucash
  describe ISIN do
    describe ".normalize" do
      it "strips spaces and hyphens and uppercases" do
        expect(ISIN.normalize("us 03783-31005")).to eq("US0378331005")
      end
    end

    describe ".valid_format?" do
      it "accepts 12 alphanumeric characters" do
        expect(ISIN.valid_format?("US0378331005")).to be true
      end

      it "rejects wrong length" do
        expect(ISIN.valid_format?("US037833100")).to be false
      end
    end
  end
end
