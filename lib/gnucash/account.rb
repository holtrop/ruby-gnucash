module Gnucash
  # Represent a GnuCash account object
  class Account
    # _String_: The name of the account (unqualified)
    attr_reader :name

    # _String_: The account description
    attr_reader :description

    # _String_: The account type (such as "EXPENSE")
    attr_reader :type

    # _String_: The GUID of the account
    attr_reader :id

    # _Array_: List of _AccountTransaction_ transactions associated with this
    # account.
    attr_reader :transactions

    # Boolean: whether the account is a placeholder or not
    attr_reader :placeholder

    # Create an Account object.
    # === Arguments
    # +book+ _Book_:: The Gnucash::Book containing the account
    # +node+ _Nokogiri::XML::Node_:: Nokogiri XML node
    def initialize(book, node)
      @book = book
      @node = node
      @name = node.xpath('act:name').text
      @type = node.xpath('act:type').text
      @description = node.xpath('act:description').text
      @id = node.xpath('act:id').text
      @parent_id = node.xpath('act:parent').text
      @parent_id = nil if @parent_id == ""
      @transactions = []
      @balances = []
      @placeholder = node.xpath("act:slots/slot").find do |slot|
        (slot.xpath("slot:key").first.text == "placeholder" and
         slot.xpath("slot:value").first.text == "true")
      end
    end

    # Return the fully qualified account name
    def full_name
      @full_name ||= calculate_full_name
    end

    # Internal method used to associate a transaction with the account
    def add_transaction(act_txn)
      @transactions << act_txn
    end

    # Internal method used to complete initialization of the Account after
    # all transactions have been associated with it.
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

    # Return the final balance of the account as a _Gnucash::Value_
    def final_balance
      return Value.new(0) unless @balances.size > 0
      @balances.last[:value]
    end

    # Return the balance of the account as of the date given as a
    # _Gnucash::Value_. Transactions that occur on the given date are included
    # in the returned balance.
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

    private

    def calculate_full_name
      prefix = ""
      if @parent_id
        parent = @book.find_account_by_id(@parent_id)
        if parent and parent.type != 'ROOT'
          prefix = parent.full_name + ":"
        end
      end
      prefix + name
    end
  end
end
