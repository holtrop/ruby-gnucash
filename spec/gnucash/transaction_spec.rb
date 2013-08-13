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

        node.should_receive(:xpath).with('trn:id').and_return(text)
        text.stub(:text) {"hi there"}
        node.should_receive(:xpath).with('trn:date-posted/ts:date').and_return(text)
        value_text.should_receive(:text).and_return("1177/100")
        account_text.should_receive(:text).and_return("a1s2d3f4")
        split_node.should_receive(:xpath).with("split:value").and_return(value_text)
        split_node.should_receive(:xpath).with("split:account").and_return(account_text)
        node.should_receive(:xpath).with('trn:description').and_return(text)
        node.should_receive(:xpath).with('trn:splits/trn:split').and_return([split_node])
        book.should_receive(:find_account_by_id).and_return(nil)

        expect { Transaction.new(book, node) }.to raise_error /Could not find account/
      end
    end

    context "without errors" do
      before(:all) do
        @book = Gnucash.open("spec/books/sample.gnucash")
        @txn = @book.find_account_by_full_name("Assets::Current Assets::Cash in Wallet").transactions.first
      end

      it "keeps track of the transaction description" do
        @txn.description.should == "Opening Balance"
      end
    end
  end
end
