require "zlib"
require "nokogiri"

module Gnucash
  class Book
    attr_accessor :accounts
    attr_accessor :transactions

    def initialize(fname)
      @ng = Nokogiri.XML(Zlib::GzipReader.open(fname).read)
      book_nodes = @ng.xpath('/gnc-v2/gnc:book')
      if book_nodes.count != 1
        raise "Error: Expected to find one gnc:book entry"
      end
      @book_node = book_nodes.first
      build_accounts
      build_transactions
      finalize
    end

    def find_account_by_id(id)
      @accounts.find { |a| a.id == id }
    end

    private

    def build_accounts
      @accounts = @book_node.xpath('gnc:account').map do |act_node|
        Account.new(self, act_node)
      end
    end

    def build_transactions
      @transactions = @book_node.xpath('gnc:transaction').map do |txn_node|
        Transaction.new(self, txn_node)
      end
    end

    def finalize
      @accounts.each do |account|
        account.finalize
      end
    end
  end
end
