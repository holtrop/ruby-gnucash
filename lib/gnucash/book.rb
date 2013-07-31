require "zlib"
require "nokogiri"

module Gnucash
  class Book
    attr_accessor :accounts

    def initialize(fname)
      @ng = Nokogiri.XML(Zlib::GzipReader.open(fname).read)
      book_nodes = @ng.xpath('/gnc-v2/gnc:book')
      if book_nodes.count != 1
        raise "Error: Expected to find one gnc:book entry"
      end
      @book_node = book_nodes.first
      build_accounts
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
  end
end
