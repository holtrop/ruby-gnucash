module Gnucash
  describe Book do
    context "with errors" do
      it "raises an error for unexpected XML" do
        gr = "gr"
        expect(Zlib::GzipReader).to receive(:open).and_return(gr)
        expect(gr).to receive(:read).and_return(nil)
        ng = "ng"
        expect(Nokogiri).to receive(:XML).and_return(ng)
        expect(ng).to receive(:xpath).with('/gnc-v2/gnc:book').and_return([])

        expect { Gnucash::Book.new('file name') }.to raise_error "Error: Expected to find one gnc:book entry"
      end
    end

    context "without errors" do
      before(:all) do
        # just open the test file once
        @subject = Gnucash.open("spec/books/sample.gnucash")
      end

      it "records the date of the earliest transaction" do
        expect(@subject.start_date).to eq Date.parse("2007-01-01")
      end

      it "records the date of the last transaction" do
        expect(@subject.end_date).to eq Date.parse("2012-12-28")
      end

      it "lets you find an account by id" do
        expect(@subject.find_account_by_id("67e6e7daadc35716eb6152769373e974").name).to eq "Savings Account"
      end

      it "lets you find an account by full name" do
        expect(@subject.find_account_by_full_name("Assets:Current Assets:Savings Account").id).to eq "67e6e7daadc35716eb6152769373e974"
      end

      it "avoid inspection of heavier attributes" do
        expect(@subject.inspect).to eq "#<Gnucash::Book start_date: 2007-01-01, end_date: 2012-12-28>"
      end
    end
  end
end
