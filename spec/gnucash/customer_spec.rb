module Gnucash
  describe Customer do
    @@addr_1 = "\n    Joe Doe jr\n    Main Street 7\n    3rd floor\n    adress 3rd line\n    adress 4th line\n    +41 55 612 20 54\n    +41 55 612 20 55\n    joe.doe@gmail.com\n  "
    @@addr_2 = "\n    Joe Doe sr\n    Main Street 1\n    line 2\n    line 3\n    line 4\n    +41 612 20 55\n    +41 612 20 56\n    joe.doe@gmail-copy.com\n  "
    
    before(:all) do
      # just read the file once
      @book = Gnucash.open("spec/books/sample.gnucash")
      @joe_doe =  @book.find_customer_by_full_name("Joe Doe")
    end

    it "gives access to the name" do
      expect(@joe_doe.name).to eq "Joe Doe"
    end

    it "gives access to the full name" do
      expect(@joe_doe.full_name).to eq "Joe Doe"
    end

    it "gives access to the guid" do
      expect(@joe_doe.guid).to eq "0938eaff7545d7ba45fe7b866d60a209"
    end

    it "gives access to the ID" do
      expect(@joe_doe.id).to eq "8765"
    end

    it "gives access to the address" do
      expect(@joe_doe.address).to eq @@addr_1
    end

    it "gives access to the shipping address" do
      expect(@joe_doe.shipping_address).to eq @@addr_2
    end

    it "avoid inspection of heavier attributes" do
      expect(@joe_doe.inspect).to eq "#<Gnucash::Customer id: 8765, name: Joe Doe, guid: 0938eaff7545d7ba45fe7b866d60a209" +
          ", address: " + @@addr_1 + 
          ", shipping_address: " + @@addr_2 + ">"
    end
  end
end
