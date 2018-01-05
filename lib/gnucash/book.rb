require "zlib"
require "nokogiri"

module Gnucash
  # Represent a GnuCash Book.
  class Book
    include Support::LightInspect

    # @return [Array<Account>] Accounts in the book.
    attr_reader :accounts

    # @return [Array<Transaction>] Transactions in the book.
    attr_reader :transactions

    # @return [Date] Date of the first transaction in the book.
    attr_reader :start_date

    # @return [Date] Date of the last transaction in the book.
    attr_reader :end_date

    # Construct a Book object.
    #
    # Normally called internally by {Gnucash.open}.
    #
    # @param fname [String]
    #   The file name of the GnuCash file to open. Only XML format (or gzipped
    #   XML format) GnuCash data files are recognized.
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
    #
    # @param id [String] GUID.
    #
    # @return [Account, nil] Account object, or nil if not found.
    def find_account_by_id(id)
      @accounts.find { |a| a.id == id }
    end

    # Return a handle to the Account object that has the given fully-qualified
    # name.
    #
    # @param full_name [String]
    #   Fully-qualified account name (ex: "Expenses::Auto::Gas").
    #
    # @return [Account, nil] Account object, or nil if not found.
    def find_account_by_full_name(full_name)
      @accounts.find { |a| a.full_name == full_name }
    end

    # Attributes available for inspection
    #
    # @return [Array<Symbol>] Attributes used to build the inspection string
    # @see Gnucash::Support::LightInspect
    def attributes
      %i[start_date end_date]
    end

    private

    # @return [void]
    def build_accounts
      @accounts = @book_node.xpath('gnc:account').map do |act_node|
        Account.new(self, act_node)
      end
    end

    # @return [void]
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

    # @return [void]
    def finalize
      @accounts.sort! do |a, b|
        a.full_name <=> b.full_name
      end
      @accounts.each do |account|
        account.finalize
      end
    end
  end
end
