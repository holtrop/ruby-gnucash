module Gnucash
  class Account
    attr_accessor :name
    attr_accessor :type
    attr_accessor :id
    attr_accessor :transactions

    def initialize(book, node)
      @book = book
      @node = node
      @name = node.xpath('act:name').text
      @type = node.xpath('act:type').text
      @id = node.xpath('act:id').text
      @parent_id = node.xpath('act:parent').text
      @parent_id = nil if @parent_id == ""
      @transactions = []
    end

    def full_name
      prefix = ""
      if @parent_id
        parent = @book.find_account_by_id(@parent_id)
        if parent and parent.type != 'ROOT'
          prefix = parent.full_name + "::"
        end
      end
      prefix + name
    end

    def add_transaction(txn, value)
      @transactions << {
        txn: txn,
        value: value,
      }
    end

    def finalize
      @transactions.sort! do |a, b|
        a[:txn].date <=> b[:txn].date
      end
    end
  end
end
