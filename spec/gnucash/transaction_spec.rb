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
        expect(@book.transactions.first.inspect).to match /#<Gnucash::Transaction.*12efba30f14dc6cd4c3ffe2994de8284.*2007-01-01.*Opening Balance/
      end
    end
  end
end
