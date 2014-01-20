module Gnucash
  describe Book do
    context "with errors" do
      it "raises an error for unexpected XML" do
        gr = "gr"
        Zlib::GzipReader.should_receive(:open).and_return(gr)
        gr.should_receive(:read).and_return(nil)
        ng = "ng"
        Nokogiri.should_receive(:XML).and_return(ng)
        ng.should_receive(:xpath).with('/gnc-v2/gnc:book').and_return([])

        expect { Gnucash::Book.new('file name') }.to raise_error "Error: Expected to find one gnc:book entry"
      end
    end

    context "without errors" do
      before(:all) do
        # just open the test file once
        @subject = Gnucash.open("spec/books/sample.gnucash")
      end

      it "records the date of the earliest transaction" do
        @subject.start_date.should == "2007-01-01"
      end

      it "records the date of the last transaction" do
        @subject.end_date.should == "2012-12-28"
      end

      it "lets you find an account by id" do
        @subject.find_account_by_id("67e6e7daadc35716eb6152769373e974").name.should == "Savings Account"
      end

      it "lets you find an account by full name" do
        @subject.find_account_by_full_name("Assets:Current Assets:Savings Account").id.should == "67e6e7daadc35716eb6152769373e974"
      end
    end
  end
end
