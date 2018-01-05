module Gnucash
  describe AccountTransaction do
    before(:all) do
      @book = Gnucash.open("spec/books/sample.gnucash")
      @txn = @book.find_account_by_full_name("Assets:Current Assets:Cash in Wallet").transactions.first
    end

    it "keeps track of the transaction description" do
      expect(@txn.description).to eq "Opening Balance"
    end

    it "avoid inspection of heavier attributes" do
      expect(@txn.inspect).to eq "#<Gnucash::AccountTransaction value: 100.00>"
    end
  end
end
