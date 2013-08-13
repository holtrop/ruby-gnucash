require "zlib"
require "nokogiri"

module Gnucash
  # Represent a GnuCash Book
  class Book
    # _Array_ of _Gnucash::Account_ objects in the book
    attr_accessor :accounts

    # _Array_ of _Gnucash::Transaction_ objects in the book
    attr_accessor :transactions

    # _String_ in "YYYY-MM-DD" format of the first transaction in the book
    attr_accessor :start_date

    # _String_ in "YYYY-MM-DD" format of the last transaction in the book
    attr_accessor :end_date

    # Construct a Book object.
    # Normally called internally by Gnucash.open()
    # === Arguments
    # +fname+ _String_:: The file name of the GnuCash file to open.
    def initialize(fname)
      begin
        @ng = Nokogiri.XML(Zlib::GzipReader.open(fname).read)
      rescue Zlib::GzipFile::Error
        @ng = Nokogiri.XML(File.read(fname))
      end
      book_nodes = @ng.xpath('/gnc-v2/gnc:book')
      if book_nodes.count != 1
        raise "Error: Expected to find one gnc:book entry"
      end
      @book_node = book_nodes.first
      build_accounts
      build_transactions
      finalize
    end

    # Return a handle to the Account object that has the given GUID.
    # === Arguments
    # +id+ _String_:: GUID
    # === Return
    # _Gnucash::Account_ or +nil+
    def find_account_by_id(id)
      @accounts.find { |a| a.id == id }
    end

    # Return a handle to the Account object that has the given fully-qualified
    # name.
    # === Arguments
    # +full_name+ _String_::
    #   Fully-qualified account name (ex: "Expenses::Auto::Gas")
    # === Return
    # _Gnucash::Account_ or +nil+
    def find_account_by_full_name(full_name)
      @accounts.find { |a| a.full_name == full_name }
    end

    private

    def build_accounts
      @accounts = @book_node.xpath('gnc:account').map do |act_node|
        Account.new(self, act_node)
      end
    end

    def build_transactions
      @start_date = nil
      @end_date = nil
      @transactions = @book_node.xpath('gnc:transaction').map do |txn_node|
        Transaction.new(self, txn_node).tap do |txn|
          @start_date = txn.date if @start_date.nil? or txn.date < @start_date
          @end_date = txn.date if @end_date.nil? or txn.date > @end_date
        end
      end
    end

    def finalize
      @accounts.each do |account|
        account.finalize
      end
    end
  end
end
