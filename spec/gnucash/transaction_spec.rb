module Gnucash
  describe Transaction do
    context "with errors" do
      it "raises an error for unexpected XML" do
        book = "book"
        node = "node"
        text = "text"
        split_node = "split_node"
        value_text = "value_text"
        account_text = "account_text"
        date_text = "date_text"

        allow(text).to receive(:text) {"hi there"}
        expect(node).to receive(:xpath).with('trn:id').and_return(text)
        expect(date_text).to receive(:text).and_return("2014-01-20")
        expect(node).to receive(:xpath).with('trn:date-posted/ts:date').and_return(date_text)
        expect(value_text).to receive(:text).and_return("1177/100")
        expect(account_text).to receive(:text).and_return("a1s2d3f4")
        expect(split_node).to receive(:xpath).with("split:quantity").and_return(value_text)
        expect(split_node).to receive(:xpath).with("split:account").and_return(account_text)
        expect(node).to receive(:xpath).with('trn:description').and_return(text)
        expect(node).to receive(:xpath).with('trn:splits/trn:split').and_return([split_node])
        expect(book).to receive(:find_account_by_id).and_return(nil)

        expect { Transaction.new(book, node) }.to raise_error /Could not find account/
      end
    end

    context "without errors" do
      before(:all) do
        @book = Gnucash.open("spec/books/sample.gnucash")
      end

      it "avoid inspection of heavier attributes" do
        expect(@book.transactions.first.inspect).to eq "#<Gnucash::Transaction id: 12efba30f14dc6cd4c3ffe2994de8284, date: 2007-01-01, description: Opening Balance, splits: [{:account=>#<Gnucash::Account id: 849f778995e8ecf8d4b96940afbbdcd7, name: Checking Account, description: Checking Account, type: BANK, placeholder: , parent_id: c8e868259d70f6491f9e70ffdf6634ee>, :value=>#<Gnucash::Value val: 30000, div: 100>}, {:account=>#<Gnucash::Account id: 23bea6468ee7b4acb4db4b3f54598a71, name: Opening Balances, description: Opening Balances, type: EQUITY, placeholder: , parent_id: ea7fe8b8abd560bef49826f68387ca78>, :value=>#<Gnucash::Value val: -30000, div: 100>}]>"
      end
    end
  end
end
