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
      @balances = []
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

    def add_transaction(act_txn)
      @transactions << act_txn
    end

    def finalize
      @transactions.sort! { |a, b| a.date <=> b.date }
      balance = Value.new(0)
      @balances = @transactions.map do |act_txn|
        balance += act_txn.value
        {
          date: act_txn.date,
          value: balance,
        }
      end
    end

    def final_balance
      return Value.new(0) unless @balances.size > 0
      @balances.last[:value]
    end

    def balance_on(date)
      return Value.new(0) unless @balances.size > 0
      return Value.new(0) if @balances.first[:date] > date
      return @balances.last[:value] if date >= @balances.last[:date]
      imin = 0
      imax = @balances.size - 2
      idx = imax / 2
      until @balances[idx][:date] <= date and @balances[idx + 1][:date] > date
        if @balances[idx][:date] <= date
          imin = idx + 1
        else
          imax = idx
        end
        idx = (imin + imax) / 2
      end
      @balances[idx][:value]
    end
  end
end
