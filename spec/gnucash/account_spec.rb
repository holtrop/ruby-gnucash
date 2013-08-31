module Gnucash
  describe Account do
    before(:all) do
      # just read the file once
      @book = Gnucash.open("spec/books/sample.gnucash")
      @assets = @book.find_account_by_full_name("Assets")
      @checking = @book.find_account_by_full_name("Assets::Current Assets::Checking Account")
      @income = @book.find_account_by_full_name("Income")
      @salary = @book.find_account_by_full_name("Income::Salary")
    end

    it "gives access to the account name" do
      @salary.name.should == "Salary"
    end

    it "gives access to the account description" do
      @checking.description.should == "Checking Account"
    end

    it "gives access to the fully-qualified account name" do
      @checking.full_name.should == "Assets::Current Assets::Checking Account"
    end

    it "gives access to the final balance" do
      @checking.final_balance.should == Value.new(19743000)
    end

    describe '.balance_on' do
      it "returns 0 if the given date is before the account's first transaction" do
        @checking.balance_on("2006-12-12").should == Value.new(0)
      end

      it "returns the final balance if the given date is after the account's last transaction" do
        @checking.balance_on("2013-10-10").should == @checking.final_balance
      end

      it "returns the balance on the given date" do
        @checking.balance_on("2012-12-25").should == Value.new(19688000)
      end

      it "includes transactions that occur on the given date" do
        @checking.balance_on("2007-03-27").should == Value.new(780000)
      end
    end

    it "stores whether the account was a placeholder" do
      @assets.placeholder.should be_true
      @checking.placeholder.should be_false
      @income.placeholder.should be_true
      @salary.placeholder.should be_false
    end
  end
end
